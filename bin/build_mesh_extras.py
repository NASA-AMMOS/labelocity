#
# build_mesh_extras.py

import argparse
import json
import os



#############################
#
#  writeJsonFile
#
############################# 
def writeJsonFile(d, jsonFileOut):
    # d is a dictionary which will be saved as text to a file
    # open output file and write json to it
    f = open(jsonFileOut,'w')
    out_json = json.dumps(d, sort_keys=False, indent=4)
    f.write(out_json)
    f.close()
    
    return

#####################################
#
#   getTimesStr
#
# a date time string to use as a filename addition to make it unique
#####################################
def getTimesStr():
    i = datetime.datetime.now()
    ts = i.strftime('%Y%m%d_%H-%M-%S.%f')
    return ts


#########################################################
#
# The MAIN
#
##########################################################
if __name__ == "__main__":
    
    if __name__ == '__main__':
        
        parser = argparse.ArgumentParser(description='count number of values for each well')
        # required=True,
        parser.add_argument('--in', help='input file name', default="")
        parser.add_argument('--out', help='output file name', default="")
        parser.add_argument('--mtl', help='input mtl file name', default="")
        parser.add_argument('--base', help='base json file name', default="")
        # , action='append' only for py 3.0
        parser.add_argument('-k', '--key_value', help='key=value. Can be called many times and it add each key=value to json. the key=value must be in quotes', default="")
        
        parser.add_argument('-o', '--output_dir', help='output directory',default=".")
        parser.add_argument('-d', '--debug', help='debug flag', action='store_true', default=False)
        
        # site_json os a file of site information created by getSites.py. It includes the elevation of a site which can be useful for wells
        args = parser.parse_args()
        # 
        
        # add a new argument for siteType=ST LK   GW = (well ??)
        # use siteType instead of parameterCD
        # python /Volumes/bigraid/msam/bin/build_mesh_extras.py --in D001L0264_551781289XYZ_G0136_0010M1.VIC --mtl D001L0264_551781289RAS_F0136_0010M1.mtl-k water=wine --key_value dog=cat
        
        # python /Volumes/bigraid/msam/bin/build_mesh_extras.py --in D001L0264_551781289XYZ_G0136_0010M1.VIC --mtl D001L0264_551781289RAS_F0136_0010M1.mtl  -k "water=wine,dog=cat" --base /Volumes/bigraid/msam/bin/insight_base_velocity_extras.json
        #######################################
        # geotif_filename = sys.argv[1]
        # netcdf_filename = sys.argv[2]
        # input_time_string = sys.argv[3]
        argsDict = args.__dict__
        in_file = argsDict['in']
        out_file = argsDict['out']
        in_path = os.path.dirname(in_file)
        in_fname_parts = in_file.split('/')
        partsCt = len(in_fname_parts)
        base_fname = in_fname_parts[partsCt -1]
        base_fname_parts = base_fname.split('.')
        ext = base_fname_parts[1]
        
        print ("in_file = %s " % (in_file))
        print ("in_path = %s  partsCt = %d %s, %s %s" % (in_path, partsCt, base_fname, base_fname_parts[0], base_fname_parts[1]))
        
        
        
        if out_file == "":
            print ("construct the out_file name since none was provided. Write to same dir as input")
            out_file = in_file.replace("."+ext, ".json")
            
            # get the base and ext, new ext is json
        mtl_file = argsDict['mtl']
        base_json_file = argsDict['base']
        output_dir = argsDict['output_dir']
        key_value = argsDict['key_value']
        
        cwd = os.getcwd()
        print ("cwd=%s" % (cwd))
        
        
        print ("output_dir = %s " % (output_dir))
        print ("out_file = %s " % (out_file))
        print ("mtl_file = %s " % (mtl_file))
        print ("base_json_file = %s " % (base_json_file))
        print ("output_dir = %s " % (output_dir))
        
        
    
        
        # print ("key_value = %s " % (key_value))
        print("key_value: %s" % (key_value))
        words = key_value.split(',')
        wordCt = len(words)
        # split each pair again, add to the base_json
        
        if base_json_file != "":
            with open(base_json_file) as data_file:
                base_json = json.load(data_file)
        else:
            base_json = {}
            
        out_json = json.dumps(base_json, sort_keys=False, indent=4)
        print (out_json)
        words = key_value.split(',')
        wordCt = len(words)
        # split each pair again, add to the base_json
        for kv in words:
            print ("kv = %s" % (kv))
            keyAndValue = kv.split("=")
            if len(keyAndValue) == 2:
                base_json[keyAndValue[0].upper()] = keyAndValue[1]
        
        
        
        
        os.chdir(output_dir)
        cwd = os.getcwd()
        print ("# cwd=%s" % (cwd))
        pngs = []
        with open(mtl_file, "r") as lines:
                    
            for line in lines:
                line = line.strip()
                if line != "":
                    
                    # map_Kd NLA_411614614RASLF0051986NCAM00346M1.png
                    # remove any # first word is key, join the other words if there is a ()
                    # test case with multiple values
                    
                    if line[0] == "#":
                        # remove the #
                        words = line.replace("#","").split()
                        wordsCt = len(words)
                        print ("line_ # = %s %d" % (line, wordsCt))
                        if wordsCt == 2:
                            key = words[0].upper()
                            value= words[1]
                            print ("key=%s value=%s" % (key, value))
                            base_json[key] = value
                        elif wordsCt > 2:
                            key = words[0].upper()
                            words2 = words[1:]
                            value = "".join(words2)
                            print ("key=%s value=%s" % (key, value))
                            base_json[key] = value
                            
                        
                    if line.find("map_Kd") != -1:
                        words = line.split()
                        wordsCt = len(words)
                        print ("map_Kd = %s %d" % (line, wordsCt))
                        if wordsCt == 2:
                            print ("map_Kd pngs = %s wordsCt=%s %s %s" % (line, wordsCt, words[0], words[1]))
                            pngs.append(words[1])
        
        pngs_str = ",".join(pngs)
        
        print ("pngs_str = %s" % (pngs_str))
        base_json['PNGS'] = "(%s)" % (pngs_str)
        
        writeJsonFile(base_json, out_file)
        