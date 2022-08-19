import arcpy,os,time,glob
from arcpy import env
from arcpy.sa import *

# Set environment settings
out_gdb = r"C:\Users\JEEVA\Documents\ArcGIS\Default.gdb"
env.workspace = "D:\\GIS\\"
env.mask = "D:\\GIS\\TNdist.shp"
env.extent= "D:\\GIS\\TNdist.shp"
arcpy.env.parallelProcessingFactor = "100%"
arcpy.env.overwriteOutput = True

# Set local variables
outPath = "D:\\GIS\\climate_out\\idw\\"
inPath="D:\\GIS\\climate_in\\"
mxd=arcpy.mapping.MapDocument(r"D:\GIS\idw-yield.mxd")
df = arcpy.mapping.ListDataFrames(mxd, "*")[0]
for file in os.listdir(inPath):
     print file
     infile=inPath+file
     out_table=os.path.splitext(file)[0]
     print out_table
     in_table=out_gdb+"/"+out_table
     out_layer=out_table
     if file.endswith(".csv"):
        print "csv-detected"
        #arcpy.management.Delete(out_table)
        arcpy.TableToTable_conversion(infile,out_gdb, out_table)
        arcpy.mapping.TableView(out_gdb + "/" + out_table)
        #arcpy.mapping.AddTableView(df, out_table)
        arcpy.RefreshActiveView()
        arcpy.MakeXYEventLayer_management(in_table,"LONG","LAT",out_table)
        arcpy.SaveToLayerFile_management(out_table, out_layer)
        input = out_table
        cellSize = 0.037078076
        power = 3
        searchRadius = RadiusVariable(12, 100000)
        arcpy.CheckOutExtension("Spatial")
        # getting the name of fields 
        zfield = [f.name for f in arcpy.ListFields(input)]
        #printing the zfield for selection of necessary fields 
        zfield
        # removing the latitude longitude field by defining size of field 
        # here in this case i have removed first 4 field
        zfield = zfield[3::]
        #loop for selecting the z value 
        for f in zfield:
            outfile = outPath + out_table + "_"+ f
            outIDW = Idw(input, f, cellSize, power, searchRadius)
            outIDW.save( outfile + ".tif")        # change the /path/ to the folder where output to be saved 
            
