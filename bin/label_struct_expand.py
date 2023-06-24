#!/usr/bin/env python

import argparse
from collections import OrderedDict

import os
import calendar
import time
import logging

logger = logging.getLogger(__name__)

struct_label_name = "^STRUCTURE"

# This script will scan across a detached label file for 
# label lines containing:
#   ^STRUCTURE = 'filename.fmt'
# and replace that line with the contents of filename.fmt.
#
# Notes: 
# 1) The filename from label and actual filename may have different casing
# 2) The new contents might itself have a ^STRUCTURE entry, so the scan
#    repeats until no new entries are expanded.
# 3) If a format file is not found, and error will be written to that 
#    line
#  


class FileUtil:
    """
    Collection of file utility methods
    """
    def __init__(self):
        pass

    @classmethod
    def getfile_insensitive(cls, directory, filename):
        """
        Returns path for an existing file within a directory
        that matches the filename argument, ignoring case.
        If no matching file is found, None is returned.
        """
        for f in os.listdir(directory):
            newpath = os.path.join(directory, f)
            if os.path.isfile(newpath) and f.lower() == filename.lower():
                return newpath
        return None

    @classmethod
    def isfile_insensitive(cls, directory, filename):
        """
        Checks if file exists within a directory
        that matches the filename argument, ignoring case.
        """
        return cls.getfile_insensitive(directory, filename) is not None

    @classmethod
    def get_format_filepath(cls, directory, name):
        """
        Wraps getfile_insensitive(), with options to modidy the 
        input/output if needed....
        """
        return cls.getfile_insensitive(directory, name)

    @classmethod
    def get_timestamp_label_filename(cls, orig):
        current_GMT = time.gmtime()
        timestamp = calendar.timegm(current_GMT)

        input_base = os.path.basename(orig)
        file_noext = input_base
        file_ext = ''        
        if "." in input_base:
            split_tup = os.path.splitext(input_base)
            file_noext = split_tup[0]
            file_ext = split_tup[1]

        return f"{file_noext}_{timestamp}{file_ext}"


class LabelUtil:
    """
    Collection of label parsing utility methods
    """
    def __init__(self):
        pass

    @classmethod
    def leading_white(cls, string):
        if string is not None:
            return string[0:string.find(string.strip())]
        else:
            return None

    @classmethod
    def is_struct_pointer_line(cls, line):
        """
        Examines line to see if it starts with '^STRUCTURE'
        """
        line = line.strip()
        return line.startswith(struct_label_name)

    @classmethod
    def get_label_value(cls, line):
        """
        Returns the value from a simple key=value label
        where everything is on same line.
        """
        if '=' in line:
            line_parts = line.split("=")
            value = line_parts[1]
            value = value.strip()
            value = value.replace('"', '')
            return value
        return None


class IoUtil:
    """
    Collection of input/output utility methods
    """
    def __init__(self):
          pass

    @classmethod
    def read_file_as_list(cls, filepath):
        """
        Reads a file and returns the contents as a 
        list of lines, with newlines removed
        """
        contents = None
        if os.path.isfile(filepath):
            with open(filepath) as file:
                contents = file.read().splitlines()
        return contents

    @classmethod
    def write_list_as_file(cls, lines, outfilepath):
        with open(outfilepath, 'w') as fp:
            for line in lines:
                fp.write(f"{line}\n")


class StructExpander:

    def __init__(self, input, output, fmt_dir):
        """
        Creates a StructExpander instance.
        """
        self.input = input
        self.output = output
        self.fmt_dir = fmt_dir
        self.expansion_count = 0
        self.expansion_errors = 0

    def perform_replacement(self, contents, line, fmt_path):
        """
        Given an array of content lines, a line, and an associated
        format file path, locates the line within contents, and replaces
        it with an expansion of the the format file contents.
        """
        line_idx = contents.index(line)
        if line_idx < 0:
            logger.error(f"Unable to locate line in contents: {line}")
            return False

        struct_value = LabelUtil.get_label_value(line)

        # we will insert the new stuff after the line
        insert_idx = line_idx + 1

        whitespace_prefix = LabelUtil.leading_white(line)

        insert_list = IoUtil.read_file_as_list(fmt_path)
        if insert_list is None:
            logger.error(f"Unable to read contents of: {fmt_path}")
            warning_cmt = f"/* Error: Was unable to read contents from {fmt_path} */"
            contents.insert(insert_idx, warning_cmt)
            return False

        info_msg = f"Expanding {struct_value} with {fmt_path}..." if struct_value is not None else \
                   f"Expanding {fmt_path}..."
        logger.info(info_msg)

        # Comments to be included in the inserted list
        comment_1 = f"/* Replacing ^STRUCTURE with referenced file contents */"
        comment_2 = f"/* Original line: {line} */"
        comment_3 = f"/* START_EXPANSION: {fmt_path} */"
        comment_N = f"/* END_EXPANSION: {fmt_path} */"
        
        insert_list.insert(0, whitespace_prefix+comment_3)
        insert_list.insert(0, whitespace_prefix+comment_2)
        insert_list.insert(0, whitespace_prefix+comment_1)
        insert_list.append(whitespace_prefix+comment_N)
        
        # Insert the insert_list within the contents
        contents[insert_idx:insert_idx] = insert_list

        #remove the original line from contents
        contents.pop(line_idx)
        
        return True

    def mark_cannot_replace(self, contents, line):
        """
        Locates line for which expansion cannot occur and
        marks it with a comment
        """
        whitespace_prefix = LabelUtil.leading_white(line)
        struct_value = LabelUtil.get_label_value(line)
        if struct_value is not None:
            line_idx = contents.index(line)
            insert_idx = line_idx
            warning_cmt = f"/* Error: Was unable to expand {struct_value} */"
            contents.insert(insert_idx, whitespace_prefix+warning_cmt)

    def run(self):
        """
        Runs the conversion process until no more '^STRUCTURE' labels
        can be expanded, then writes the results to the output file
        """

        # Map from label struct name to the associated file path
        struct_name_to_path_dict = dict()

        # Keep track of lines that we marked as having no FMT match
        lines_with_no_match = []

        # List of struct names with no associated file path
        missing_struct_files = []

        # Flag which controls when we can stop scanning
        repeat_scan = True

        logger.info(f"Reading from {self.input}...")
        contents = IoUtil.read_file_as_list(self.input)
        if contents is None:
            logger.error(f"Could not load the contents of input file: {self.input}")
            repeat_scan = False

        while repeat_scan:

            # reset for each iteration
            conversion_performed = False
            line_to_fmt_dict = dict()

            for line in contents:
                
                if LabelUtil.is_struct_pointer_line(line):
                    struct_value = LabelUtil.get_label_value(line)
                
                    if struct_value is not None:
                        fmt_filepath = None
                        if struct_value in missing_struct_files:
                            pass
                        elif struct_value in struct_name_to_path_dict.keys():
                            fmt_filepath = struct_name_to_path_dict[struct_value]
                        else:
                            # Now we need to see if the associated file exists.
                            # If so, then add to the dict, else mark it as missing.

                            # get filepath of struct file
                            fmt_filepath = FileUtil.get_format_filepath(self.fmt_dir, struct_value)

                            if fmt_filepath is None:
                                logger.error(f"No file was found for {struct_value}")
                                if struct_value not in missing_struct_files:
                                    missing_struct_files.append(struct_value)
                            else:
                                struct_name_to_path_dict[struct_value] = fmt_filepath

                        ## Associate fmt path (or None) with the line
                        if fmt_filepath is not None:
                            line_to_fmt_dict[line] = fmt_filepath
                        else:
                            line_to_fmt_dict[line] = None

            for line, fmt_path in line_to_fmt_dict.items():
                if fmt_path:
                    replace_success = self.perform_replacement(contents, line, fmt_path)
                    if replace_success:
                        self.expansion_count += 1
                        conversion_performed = True
                    else:
                        self.expansion_errors += 1
                elif line not in lines_with_no_match:
                    self.mark_cannot_replace(contents, line)
                    conversion_performed = True
                    self.expansion_errors += 1
                    lines_with_no_match.append(line)

            if not conversion_performed:
                repeat_scan = False

        logger.info(f"Number of expansions: {self.expansion_count}")
        if self.expansion_errors > 0:
            logger.info(f"Number of expansion errors: {self.expansion_errors}")
        if missing_struct_files:
            msf_as_str = ','.join(missing_struct_files)
            logger.info(f"Structure files that were not found: {msf_as_str}")

        logger.info(f"Writing to {self.output}...")
        IoUtil.write_list_as_file(contents, self.output)


def main():

    descr = (
        "Replaces STRUCTURE pointer lines with the contents of the "
        "file referenced as the value."
    )

    parser = argparse.ArgumentParser(
        description=descr, formatter_class=argparse.ArgumentDefaultsHelpFormatter
    )

    arg_defns = OrderedDict(
        {
            "--output": {
                "type": str,
                #"default": f"output_{timestamp}.lbl",
                "help": "Output label file",
            },
            "--format_dir": {
                "type": str,
                "help": "Directory containing all of the format files."
                        "If not specified, the parent directory of the input "
                        "file will be assumed",                   
            },
            "--verbose": {
                "action": "store_true",
                "default": False,
                "help": "Enables verbose logging.",
            },
        }
    )
    arg_defns["input"] = {"type": str, "help": "Input label."}

    # Push argument defs to the parser
    for name, params in arg_defns.items():
        parser.add_argument(name, **params)

    # Get arg results of the parser
    args = parser.parse_args()

    # Extract args to local fields
    input = args.input
    output = args.output
    format_dir = args.format_dir
    verbose = args.verbose
    
    if input is None:
        raise Exception("Missing required input file")
    else:
        input_file =  os.path.abspath(input)
        if not os.path.isfile(input_file):
            raise Exception("File not found: %s " % input)

    # Create a timestamped filename as default for output
    input_base_ts_lbl = FileUtil.get_timestamp_label_filename(input_file)

    if output is None:
        output_file = os.path.abspath(input_base_ts_lbl)
    elif os.path.isdir(output):
        output_file = os.path.join(output, input_base_ts_lbl)
    else:
        output_file = os.path.abspath(output)

    if format_dir is None:
        format_dir = os.path.dirname(input)
    format_path = os.path.abspath(format_dir)

    if verbose:
        logging.basicConfig(level=logging.INFO, 
                            format='%(levelname)s: %(message)s')

    expander = StructExpander(input_file, output_file, format_path)
    expander.run()


if __name__ == "__main__":
    main()
