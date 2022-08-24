import arcpy,os,glob,time
from arcpy import env
from arcpy.sa import *
arcpy.env.parallelProcessingFactor = "100%"
arcpy.env.overwriteOutput = True

# Check out the ArcGIS Spatial Analyst extension license
arcpy.CheckOutExtension("Spatial")
inPath = "D:\\CROP_SUMMARY\\maps_out\\"
env.workspace = r"D:\\CROP_SUMMARY\\"
outPath=r"D:\\CROP_SUMMARY\\maps_out\\out\\"
#symbologyLyr = r"D:\\CROP_SUMMARY\\symbology-temp.lyr"
     
path=inPath +"*.mxd"
for file in glob.glob(path):
    mxd = arcpy.mapping.MapDocument(file)
    fnm=file.split('\\')
    fname=fnm[3].split('.')
    print (fname[0])
    legend = arcpy.mapping.ListLayoutElements(mxd, "LEGEND_ELEMENT", "Legend")[0]
    legendlayers = legend.listLegendItemLayers()
    for item in legendlayers:             
        if "YIELD" in item.name:                 
            style = arcpy.mapping.ListStyleItems("USER_STYLE", "Legend Items","yield_legend")[0]                 
            legend.updateItem(item, style) 
    
    Dtitle=arcpy.mapping.ListLayoutElements(mxd, "TEXT_ELEMENT","TITLEtext")[0]
    Dtitle.fontSize = 24
    bname=arcpy.mapping.ListLayoutElements(mxd, "TEXT_ELEMENT","Text0")[0]
    if "BASE" in bname.text:
        bname.text = "BASE (1971-2005)"
    arcpy.RefreshActiveView()
    mxd.save()
    arcpy.mapping.ExportToPNG(mxd,outPath+fname[0]+".png")
    #print ("entering sleep")
    #time.sleep(10)


#if not "DEV" in file:
#                symbologyLyr =r"D:\\CROP_SUMMARY\\symbology_"+x+".lyr"
#                dnnm=file.split('\\')
#                #print (dnnm[3])
#                dnnme=dnnm[3].split('_')
#                dnindex=intime.index(dnnme[1])
#                #print(str(dnnme[1]) + "__"+str(dnindex))
#                df=arcpy.mapping.ListDataFrames(mxd)[dnindex]
#                addLayer = arcpy.mapping.Layer(file)
#                arcpy.mapping.AddLayer(df,addLayer,"BOTTOM")
#                #print ("FILE= "+file)
#                symlayer=arcpy.mapping.Layer(symbologyLyr)
#                uplayer=arcpy.mapping.ListLayers(mxd, addLayer.name , df)[0]
#                arcpy.mapping.UpdateLayer(df,uplayer,symlayer,True)
#                for elm in arcpy.mapping.ListLayoutElements(mxd, "TEXT_ELEMENT","Text"+str(dnindex)):
#                    elm.text = str(dnnme[1]) + " ("+ str(inyear[dnindex])+")"
#                       
#        arcpy.RefreshActiveView()
#        Dtitle=arcpy.mapping.ListLayoutElements(mxd, "TEXT_ELEMENT","TITLEtext")[0]
#        lowx=x.lower()
#        Dtitle.text = "Yield of "+str(lowx)+ " under SSP"+y







#for x in intiff:
#    mxd = arcpy.mapping.MapDocument(r"D:\\CROP_SUMMARY\\"+x+"yield_maps.mxd")
#    path=inPath +x+"*.tif"
#    print path
#    dn=0
#    if "DEV" in x:
#        mxd = arcpy.mapping.MapDocument(r"D:\\CROP_SUMMARY\\"+x+"yield_dev_maps.mxd")
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
            
    
