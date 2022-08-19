import arcpy,os,glob,time
from arcpy import env
from arcpy.sa import *
arcpy.env.parallelProcessingFactor = "100%"
arcpy.env.overwriteOutput = True

intiff=["FUTURE_CON","FUTURE_SRI","HIST_CON","HIST_SRI"]
# Check out the ArcGIS Spatial Analyst extension license
arcpy.CheckOutExtension("Spatial")
inPath = "D:\\GIS\\DSSAT-YIELD-MAP\\yield_maps\\"
env.workspace = r"D:\\GIS\\"
outPath=r"D:\\GIS\\mapsout\\"
symbologyLyr = r"D:\\GIS\\symbology-temp.lyr"
mxd1 = arcpy.mapping.MapDocument(r"D:\GIS\idw-yield-out.mxd")
for filename in glob.glob(inPath+'*Shape.tif'):
    os.remove(filename)
for x in intiff:
    path=inPath +x+"*.tif"
    print path
    dn=0
    if "HIST" in x:
        mxd1 = arcpy.mapping.MapDocument(r"D:\GIS\idw-yield-hist-out.mxd")
    mxd1.saveACopy(outPath+x+".mxd")
    mxd=arcpy.mapping.MapDocument(outPath+x+".mxd")
    for file in glob.glob(path):
        df=arcpy.mapping.ListDataFrames(mxd)[dn]
        addLayer = arcpy.mapping.Layer(file)
        yrf=addLayer.name.split('_F')
        titl=yrf[1].split('.')
        arcpy.mapping.AddLayer(df,addLayer,"BOTTOM")
        symlayer=arcpy.mapping.Layer(symbologyLyr)
        uplayer=arcpy.mapping.ListLayers(mxd, addLayer.name , df)[0]
        arcpy.mapping.UpdateLayer(df,uplayer,symlayer,True)
        df.name = titl[0]
        for elm in arcpy.mapping.ListLayoutElements(mxd, "TEXT_ELEMENT","Text"+str(dn)):
            print elm.text
            elm.text = str(titl[0])
            print elm.text
        dn=dn+1
    arcpy.RefreshActiveView()
    mxd.save()
    arcpy.mapping.ExportToPNG(mxd,outPath+x+".png")
        
            
    