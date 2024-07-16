''' Copyright 2024 Ryan Christopher Bahillo. All Rights Reserved.
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
========================================================================='''

import re, os
import pandas as pd

def hex_to_c_array(hex_data) -> str:
    c_str = ''

    # Declare C variable
    c_str += 'unsigned char model[]={'
    hex_array = []

    for i, val in enumerate(hex_data):
        # Construct string from hex
        hex_str = format(val, '#04x')

        if (i + 1) < len(hex_data):
            hex_str += ','

        hex_array.append(hex_str)

    # Add closing brace
    c_str += format(''.join(hex_array)) + '};'

    return c_str


def rmv_file_spaces(file, exclude='') -> str:
    '''
        This method is to reduce memory when transferring file contents,
        because a single character (including spaces) is equal to 1 byte.
        
        This is intentionally on purpose so when user decides to download the file, it is presented properly.
    '''
    with open(file) as stream:
        contents = stream.read()
        x = re.sub('\s$', '', contents, flags=re.MULTILINE)

    if exclude != '':
        start = len(exclude)
        z = x[start:]
        parsedFile = z.replace(" ", "").replace("\n","")
        return exclude + parsedFile

    parsedFile = x.replace(" ", "").replace("\n","")
    return parsedFile

def remove_file(path: str):
    try: 
        os.remove(path)
    except PermissionError as e:
        print(e)

def callback_string(history) -> str:
    hist_df = pd.DataFrame(history.history)
    str_callback = hist_df.to_csv(index=False)
    return str_callback
    
