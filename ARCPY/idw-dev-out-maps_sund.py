import arcpy,os,glob,time
from arcpy import env
from arcpy.sa import *
arcpy.env.parallelProcessingFactor = "100%"
arcpy.env.overwriteOutput = True

incrop=["GREENGRAM","RICE","LATHYRUS"]
intime=["BASE","NEAR","SHORT","MID"]
inyear=[" ","2022-2030","2041-2050","2051-2060"]
inscen=["245","585"]
# Check out the ArcGIS Spatial Analyst extension license
arcpy.CheckOutExtension("Spatial")
inPath = "D:\\CROP_SUMMARY_SUND\\yield_out\\"
env.workspace = r"D:\\CROP_SUMMARY_SUND\\"
outPath=r"D:\\CROP_SUMMARY_SUND\\maps_out\\"
#symbologyLyr = r"D:\\CROP_SUMMARY_SUND\\symbology-temp.lyr"


for filename in glob.glob(inPath+'*Shape.tif'):
    os.remove(filename)
for y in inscen:
    for x in incrop:
        mxd1 = arcpy.mapping.MapDocument(r"D:\\CROP_SUMMARY_SUND\\yield_dev_sund_maps_temp.mxd")
        path=inPath +x+"*DEV*"+y+"*.tif"
        mxd1.saveACopy(outPath+x+"_dev_"+y+".mxd")
        mxd=arcpy.mapping.MapDocument(outPath+x+"_dev_"+y+".mxd")
        for file in glob.glob(path):
            if "DEV" in file:
                symbologyLyr =r"D:\\CROP_SUMMARY_SUND\\symb\\symbology_"+x+"_dev.lyr"
                dnnm=file.split('\\')
                print (dnnm[3])
                dnnme=dnnm[3].split('_')
                dnindex=intime.index(dnnme[1])
                print(str(dnnme[1]) + "__"+str(dnindex))
                df=arcpy.mapping.ListDataFrames(mxd)[dnindex-1]
                addLayer = arcpy.mapping.Layer(file)
                arcpy.mapping.AddLayer(df,addLayer,"BOTTOM")
                #print ("FILE= "+file)
                symlayer=arcpy.mapping.Layer(symbologyLyr)
                uplayer=arcpy.mapping.ListLayers(mxd, addLayer.name , df)[0]
                arcpy.mapping.UpdateLayer(df,uplayer,symlayer,True)
                for elm in arcpy.mapping.ListLayoutElements(mxd, "TEXT_ELEMENT","Text"+str(dnindex-1)):
                    elm.text = str(dnnme[1]) + " ("+ str(inyear[dnindex])+")"
                    print elm.text
                   
        arcpy.RefreshActiveView()
        Dtitle=arcpy.mapping.ListLayoutElements(mxd, "TEXT_ELEMENT","TITLEtext")[0]
        lowx=x.lower()
        Dtitle.text ="Percent yield deviation of "+str(lowx)+ " under SSP"+y
        mxd.save()
        arcpy.mapping.ExportToPNG(mxd,outPath+x+"_deviation_SSP"+y+".png")










#for x in intiff:
#    mxd = arcpy.mapping.MapDocument(r"D:\\CROP_SUMMARY_SUND\\"+x+"yield_maps.mxd")
#    path=inPath +x+"*.tif"
#    print path
#    dn=0
#    if "DEV" in x:
#        mxd = arcpy.mapping.MapDocument(r"D:\\CROP_SUMMARY_SUND\\"+x+"yield_dev_maps.mxd")
#for file in glob.glob(inPath+"*.tif"):  
#    fname=file.split('.')
#    #mxd1.saveACopy(outPath+fname+".mxd")
#    #mxd=arcpy.mapping.MapDocument(outPath+fname+".mxd")
#    for file in glob.glob(path):
#        df=arcpy.mapping.ListDataFrames(mxd)[dn]
#        addLayer = arcpy.mapping.Layer(file)
#        yrf=addLayer.name.split('_F')
#        titl=yrf[1].split('.')
#        arcpy.mapping.AddLayer(df,addLayer,"BOTTOM")
#        symlayer=arcpy.mapping.Layer(symbologyLyr)
#        uplayer=arcpy.mapping.ListLayers(mxd, addLayer.name , df)[0]
#        arcpy.mapping.UpdateLayer(df,uplayer,symlayer,True)
#        df.name = titl[0]
#        for elm in arcpy.mapping.ListLayoutElements(mxd, "TEXT_ELEMENT","Text"+str(dn)):
#            print elm.text
#            elm.text = str(titl[0])
#            print elm.text
#        dn=dn+1
#    arcpy.RefreshActiveView()
#    mxd.save()
#    arcpy.mapping.ExportToPNG(mxd,outPath+x+".png")
#        
            
    
