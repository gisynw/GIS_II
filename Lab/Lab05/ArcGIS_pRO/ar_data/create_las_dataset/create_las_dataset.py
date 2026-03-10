import arcpy
import os

def create_las_dataset_from_laz():
    # Set the workspace to the current directory
    workspace = r"e:\ConwayTeaching\GIS_II\GIS_II_Github\docs\Lab\Lab05\ArcGIS_pRO\ar_data"
    arcpy.env.workspace = workspace
    
    # Define the output LAS Dataset name
    output_lasd = os.path.join(workspace, "Eastern_AR_Data.lasd")
    
    # Get a list of all .laz files in the workspace
    laz_files = arcpy.ListFiles("*.laz")
    
    if not laz_files:
        print("No .laz files found in the workspace.")
        return

    print(f"Found {len(laz_files)} .laz files. Creating LAS Dataset...")
    
    # The tool can take a list of files or a folder. 
    # Here we pass the list of identified .laz files.
    try:
        # arcpy.management.CreateLasDataset(input_dataset, out_las_dataset, {folder_recursion}, ...)
        arcpy.management.CreateLasDataset(
            input=laz_files,
            out_las_dataset=output_lasd,
            folder_recursion="NO_RECURSION",
            compute_stats="COMPUTE_STATISTICS",
            relative_paths="RELATIVE_PATHS",
            spatial_reference=arcpy.SpatialReference(102651) # NAD 1983 StatePlane Arkansas North (US Feet)
        )
        print(f"Successfully created: {output_lasd}")
    except arcpy.ExecuteError:
        print(arcpy.GetMessages(2))
    except Exception as e:
        print(f"Error: {str(e)}")

if __name__ == "__main__":
    create_las_dataset_from_laz()
