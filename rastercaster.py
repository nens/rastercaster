#!/usr/bin/env python
# -*- coding: utf-8 -*-
""" TODO Docstring. """
# TODO: filler vlakjes moeten geupdate worden als een naburig vlakje is aangepast
#    Tijdelijk opgelost door alle filler vlakjes altijd opnieuw te maken aan het eind
# TODO: Bij laatste GDAL-Translate ook een progress bar weergeven
#   Lijkt niet mogelijk    
# TODO: in alle datalagen (elevation point, surface, aux) de optie relative toevoegen (default false) om interactie met base raster mogelijk te maken


from __future__ import print_function
from __future__ import unicode_literals
from __future__ import absolute_import
from __future__ import division

import argparse
import logging
import os, sys
import ConfigParser
import shutil
import psycopg2
import traceback
import subprocess
from shutil import copyfile
from osgeo import ogr, gdal, osr
from osgeo.gdalnumeric import *
from gdalconst import *

logger = logging.getLogger(__name__)

def system_custom(cmd):
    try:
        if isinstance(cmd, list):
            cmd = ' && '.join(cmd)
        process = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, shell=True)
        output, error = process.communicate()
        returncode = process.poll()
        logger.info(output)
        if returncode != 0:
            raise ValueError('Executable terminated, see log file')
    except (ValueError, IndexError):
        exit('Executable terminated, see log file')

class settingsObject:
    """Contains the settings from the ini file"""
    def __init__(self):
        self.host = 'localhost'
        self.port = 5432
    
    def read(self, inifile):
        config = ConfigParser.RawConfigParser()
        config.read(inifile)	
        
        # database
        self.host = config.get('database', 'host')
        self.port = config.get('database', 'port')
        self.username = config.get('database', 'username')
        self.password = config.get('database', 'password')
        self.database = config.get('database', 'database')

        # inputs
        self.base_raster = config.get('inputs', 'base_raster')
        
        # parameters
        self.pixelsize = config.get('parameters', 'pixelsize')
        self.filler_seg_dist = config.get('parameters', 'filler_seg_dist')
        self.elevation_point_search_radius = config.get('parameters', 'elevation_point_search_radius')
                
        # output
        self.output_file = config.get('output', 'output_file')

def db_connection(host, port, dbname, user, password):
    db_conn="dbname={dbname_value} user={user_value} host={host_value} port={port_value} password={password_value}".format(dbname_value=dbname, user_value=user, host_value=host, port_value=port, password_value=password)
    #Connect met de database
    try:
        conn = psycopg2.connect(db_conn)
    except:
        logger.info("I am unable to connect to the database")
        logger.info(db_conn)
    
    return conn

def execute_sql_command(host, port, database, username, password, sql, verbose=False):
    try:
        conn = db_connection(host, port, database, username, password)
        cur = conn.cursor()
        
        cur.execute(sql)
        if verbose==True:
            logger.debug(sql)
                
        try:
            conn.commit()

        except psycopg2.DatabaseError, e:

            if conn:
                conn.rollback()
                conn.close()
                
            logger.error('Error %s'%e)
            raise Exception('SQL Commit error')
    except:
        if conn:
                conn.close()
        print(traceback.format_exc())
        raise Exception('SQL Error')        
        
    finally:        
        if conn:
            conn.close()

def execute_sql_file(host, port, database, username, password, filename, verbose=False):
    logger.info('Started execute_sql_file:' + filename)
    try:
        conn = db_connection(host, port, database, username, password)
        cur = conn.cursor()
        
        with open(filename, 'r') as file:
            sql = file.read()
        cur.execute(sql)
        if verbose==True:
            logger.debug('execute_sql_file:' + filename)
        
        try:
            conn.commit()
        
        except psycopg2.DatabaseError, e:
            
            if conn:
                conn.rollback()
                conn.close()
                
            logger.error('Error %s'%e)
            raise Exception('SQL Commit error')
    
    except:
        if conn:
                conn.close()
        print(traceback.format_exc())
        raise Exception('SQL Error')
        
    finally:        
        if conn:
            conn.close()
        
def install(settings):

    answer = raw_input(r'Existing rastercaster data in the database will be overwritten. Are you sure? (Y/N): ')
    if answer in ('Y', 'y', 'J', 'j', 'prima joh'):
        # (create database if not exists)
        # enable postgis
        print('Enable PostGIS...')
        execute_sql_command(host=settings.host, port=settings.port, database=settings.database, username=settings.username, password=settings.password, sql='''CREATE EXTENSION IF NOT EXISTS postgis;''')
        
        # add rastercaster functions and tables to the database
        print('Add RasterCaster functions and tables to the database...')
        execute_sql_command(host=settings.host, port=settings.port, database=settings.database, username=settings.username, password=settings.password, sql='''CREATE SCHEMA IF NOT EXISTS rc;''')
        script_path = os.path.dirname(os.path.abspath(__file__))
        print(script_path)
        rastercaster_dir = os.path.join(script_path, r'sql')
        print(rastercaster_dir)
        
        for file in os.listdir(rastercaster_dir):
            filename = os.path.join(rastercaster_dir, file)
            if filename.endswith(".sql"): 
                execute_sql_file(host=settings.host, port=settings.port, database=settings.database, username=settings.username, password=settings.password, filename=filename)
                continue
            else:
                continue

        execute_sql_command(host=settings.host, port=settings.port, database=settings.database, username=settings.username, password=settings.password, sql='''DELETE FROM rc.instellingen; INSERT INTO rc.instellingen VALUES ('pixelsize','{p}'), ('filler_seg_dist','{f}'), ('elevation_point_search_radius', '{e}');'''.format(p=settings.pixelsize, f=settings.filler_seg_dist, e=settings.elevation_point_search_radius))

def cast_raster(settings):
    #________________________________________
    # get list of surface ids to be exported
    print('''Building molds...''')
    conn = db_connection(host=settings.host, port=settings.port, dbname=settings.database, user=settings.username, password=settings.password)
    cur = conn.cursor()
    try:
        sql = '''SELECT id FROM rc.surface_admin WHERE exported < updated ORDER BY id;'''
        cur.execute(sql)
        export_ids_weird_format = list(cur)
        sql = '''SELECT id FROM rc.surface_admin ORDER BY id;'''
        cur.execute(sql)
        all_ids_weird_format = list(cur)
        sql='''SELECT count(*) FROM rc.surface WHERE definition_type IN ('tin', 'filler');'''
        cur.execute(sql)
        must_fill_open_pixels = cur.fetchone()[0] > 0
        
        try:
            conn.commit()
        except psycopg2.DatabaseError, e:
            if conn:
                conn.rollback()
            logger.error('Error %s' % e)
    except psycopg2.DatabaseError:
        print(traceback.format_exc())
    finally:
        if conn:
            conn.close()

    all_ids=list()
    for id in all_ids_weird_format:
        all_ids.append(id[0])
    
    #_______________________________________________________________
    # generate (in database) partial rasters that are new or updated 
    export_ids=list()
    for id in export_ids_weird_format:
        export_ids.append(id[0])
    
    failed_ids=list()
    has_failed=False

    if len(export_ids) > 0:
        print('''Mixing gypsum...''')
        count = 0;
        for id in export_ids:
            try:
                execute_sql_command(host=settings.host, port=settings.port, database=settings.database, username=settings.username, password=settings.password, sql='''SELECT rc.update_raster({id});'''.format(id=id)) 
            except:
                has_failed=True
                failed_ids.append(id)
                continue
            try:
                count+=1;
                ogr.TermProgress_nocb((count)/len(export_ids))
            except:
                continue
                
    print('''Mixing mortar...''')
    count = 0;
    for id in all_ids:
        try:
            execute_sql_command(host=settings.host, port=settings.port, database=settings.database, username=settings.username, password=settings.password, sql='''SELECT rc.update_filler(id) FROM rc.surface WHERE id = {id} AND definition_type = 'filler';'''.format(id=id))
        except:
            has_failed=True
            failed_ids.append(id)
            continue
            
        try:
            count+=1;
            ogr.TermProgress_nocb((count)/len(all_ids))
        except:
            continue
                
    #____________________________________________________________
    # stitch all partial rasters together (base raster not involved yet)
    print('''Casting gypsum to molds...''')
    count = 0
    tifList=list()
    
    for id in all_ids:
        if id not in failed_ids:

            ds_string = "PG:host='{h}' port={p} dbname='{d}' user='{u}' password='{pw}' schema='rc' table='surface_admin' mode='2' where='id = {id}'".format(h=settings.host, p=settings.port, d=settings.database, u=settings.username, pw=settings.password, id=id)
            execute_sql_command(host=settings.host, port=settings.port, database=settings.database, username=settings.username, password=settings.password, sql='''UPDATE rc.surface_admin SET exported = now() WHERE id = {id};'''.format(id=id))
            tifList.append(ds_string)
            
            
        try:
            count+=1;
            ogr.TermProgress_nocb((count)/len(all_ids))
        except:
            continue
    
    vrtname=os.path.join('/vsimem/', r'cast.vrt')
    gdal.BuildVRT(destName=vrtname, srcDSOrSrcDSTab=tifList, srcNodata=-9999, VRTNodata=-9999, outputSRS='EPSG:28992') 
        
    cast_inmem=os.path.join('/vsimem/', r'cast.tif')
    vrt = gdal.Open(vrtname)
    tmp = gdal.Translate(destName=cast_inmem, srcDS=vrt, format='Gtiff', noData=-9999, outputSRS='EPSG:28992', outputType=gdal.GDT_Float32, creationOptions=['COMPRESS=DEFLATE'])
    tmp = None
            
    #________________
    # fill open pixels if there are any filler or tin surfaces in the raster
    print('''Drying gypsum...''')
    if must_fill_open_pixels: 
        # ### create a mask that has value 1 for all pixels outside the rc.surface polygon
        # ### ### write vrt dimensions (width, height, upperleftx, upperlefty) to database
        sql = '''
            DELETE FROM rc.instellingen WHERE variabele IN ('vrt_width', 'vrt_height', 'vrt_ulx', 'vrt_uly');
            INSERT INTO rc.instellingen (variabele, waarde) VALUES 
                ('vrt_width','{w}'), 
                ('vrt_height','{h}'), 
                ('vrt_ulx','{x}'),
                ('vrt_uly','{y}')
            ;
            SELECT rc.create_fillnodatamask();
        '''.format(w=vrt.RasterXSize,h=vrt.RasterYSize, x=vrt.GetGeoTransform()[0] ,y=vrt.GetGeoTransform()[3])
        
        execute_sql_command(host=settings.host, port=settings.port, database=settings.database, username=settings.username, password=settings.password, sql=sql)
        vrt = None
        gdal.Unlink(vrtname)
        
        mask_in_db_string = "PG:host='{h}' port={p} dbname='{d}' user='{u}' password='{pw}' schema='rc' table='fillnodatamask' mode='2'".format(h=settings.host, p=settings.port, d=settings.database, u=settings.username, pw=settings.password)
        mask_inmem1=os.path.join('/vsimem/', r'mask1.tif')
        mask_in_db = gdal.Open(mask_in_db_string)
        tmp = gdal.Translate(destName=mask_inmem1, srcDS=mask_in_db, noData=0)
        tmp = None
        mask_in_db = None
        
        # ### create a mask that has value 1 for all active pixels in the cast AND for all pixels outside the rc.surface polygon (1+1=2)
        
        m = gdal.Open(mask_inmem1, GA_ReadOnly)
        m_band = m.GetRasterBand(1)
        m_data = BandReadAsArray(m_band)
        c = gdal.Open(cast_inmem, GA_ReadOnly)
        c_band = c.GetRasterBand(1)
        c_data = BandReadAsArray(c_band)
        
        dataOut = ((c_data==-9999)+(m_data))!=2

        driver = gdal.GetDriverByName(str('GTiff'))
        mask_inmem2 = '/vsimem/mask2.tif'
        dsOut = driver.Create(str(mask_inmem2), m.RasterXSize, m.RasterYSize, 1, m_band.DataType)
        CopyDatasetInfo(m,dsOut)
        bandOut=dsOut.GetRasterBand(1)
        BandWriteArray(bandOut, dataOut)

        m_band = None
        m = None
        c_band = None
        c = None
        bandOut = None
        dsOut = None

        # ### use the created mask as input in gdal.FillNoData
        castDs = gdal.Open(cast_inmem, GA_Update)
        castBand = castDs.GetRasterBand(1)
        mask = gdal.Open(mask_inmem2)
        maskBand = mask.GetRasterBand(1)
        filled = gdal.FillNodata(targetBand = castBand, maskBand = maskBand, maxSearchDist = 2, smoothingIterations = 0)
        filled = None
        
        maskBand = None
        mask = None
        castBand = None
        castDs = None
    
    #___________________________________________               
    # make vrt of base raster and cast
    tifList = list()
    tifList.append(cast_inmem)
    # ### somehow there two versions of EPSG:28992 exist that differ in their TOWGS84 parameter
    # ### gdal treats these as different projections, and therefore will not add both to the same vrt
    # ### if this is the case, the base raster is read into memory, it's projection overwritten with the same version of EPGS:28992 as the RasterCaster output
    if settings.base_raster != '':
        base_raster_ds = gdal.Open(settings.base_raster)
        base_raster_sr = osr.SpatialReference(wkt = base_raster_ds.GetProjection())
        
        last_db_raster_ds = gdal.Open(ds_string)
        last_db_raster_sr = osr.SpatialReference(wkt = last_db_raster_ds.GetProjection())
        
        if base_raster_sr.GetAttrValue(str('authority'), 0) == last_db_raster_sr.GetAttrValue(str('authority'), 0) and base_raster_sr.GetAttrValue(str('authority'), 1) == last_db_raster_sr.GetAttrValue(str('authority'), 1):
            if base_raster_sr != last_db_raster_sr:
                print('''NOTICE: Base raster and database rasters have different definitions of the same SRS ({a}:{c}). Casting will take some extra time.'''.format(a=base_raster_sr.GetAttrValue(str('authority'), 0), c=base_raster_sr.GetAttrValue(str('authority'), 1)))
                tr = gdal.Translate(destName='/vsimem/baseraster.tif', srcDS=base_raster_ds)
                base_raster_inmem = gdal.Open('/vsimem/baseraster.tif', GA_Update)
                res = base_raster_inmem.SetProjection(last_db_raster_ds.GetProjection())
                res = None
                base_raster_inmem = None
                tifList.insert(0, '/vsimem/baseraster.tif') 
            else:
                tifList.insert(0, settings.base_raster) 
    
    vrtname=os.path.join('/vsimem/','cast.vrt')
    tmp = gdal.BuildVRT(destName=vrtname, srcDSOrSrcDSTab=tifList, srcNodata=-9999, VRTNodata=-9999, outputSRS='EPSG:28992') 
    tmp = None
    
    tmp = gdal.Translate(destName=settings.output_file, srcDS=vrtname, noData=-9999, stats=True, outputType=gdal.GDT_Float32, creationOptions=['COMPRESS=DEFLATE'])
    tmp = None
    castDs=None
    
    if has_failed==True:
        print('Warning: rasters for some surfaces were not succesfully generated. IDs: {f}'.format(f=failed_ids))
    else:
        print('Rasters for all surfaces were succesfully generated.')

    print('Done! Raster has been cast to {o}'.format(o=settings.output_file))
    
def aux(settings):
    # delete autogenerated aux geoms and generate them again
    sql = '''DELETE FROM rc.auxiliary_line WHERE autogenerated;'''
    sql += '''SELECT rc.ApproxAuxLines(id) FROM rc.surface;'''
    execute_sql_command(host=settings.host, port=settings.port, database=settings.database, username=settings.username, password=settings.password, sql=sql);
    
def rastercaster(**kwargs):
    # read inifile
    print('Read inifile')
    settings = settingsObject()
    settings.read(kwargs['inifile'])
    
    if kwargs['install']==True:
        print('Installing rastercaster from {ini}'.format(ini=kwargs['inifile']))
        install(settings)
    elif kwargs['cast']==True:
        if kwargs['full']==True:
                execute_sql_command(host=settings.host, port=settings.port, database=settings.database, username=settings.username, password=settings.password, sql='''UPDATE rc.surface_admin SET updated = now();''');
        print('Casting raster from {ini}'.format(ini=kwargs['inifile']))
        cast_raster(settings)
    elif kwargs['aux']==True:
        print('Generating auxiliary lines for {ini}'.format(ini=kwargs['inifile']))
        aux(settings)
    return 0


def get_parser():
    """ Return argument parser. """
    parser = argparse.ArgumentParser(
        description=__doc__
    )
    parser.add_argument('inifile', metavar='INIFILE')
    parser.add_argument('-install', default=False, help='Install RasterCaster into database', dest='install', action='store_true')
    parser.add_argument('-cast', default=False, help='Cast raster (export from database to tif)', dest='cast', action='store_true')
    parser.add_argument('-full', default=False, help='Regenerate partial rasters for all surfaces before casting', dest='full', action='store_true')
    parser.add_argument('-aux', default=False, help='Generate auxiliary lines for all surfaces. Existing autogenerated lines are overwritten.', dest='aux', action='store_true')

    return parser


def main():
    """ Call command with args from parser. """
    kwargs = vars(get_parser().parse_args())

    logging.basicConfig(stream=sys.stderr,
                        level=logging.DEBUG,
                        format='%(message)s')

    try:
        return rastercaster(**kwargs)
    except:
        logger.exception('An exception has occurred.')
        return 1


if __name__ == '__main__':
    exit(main())
