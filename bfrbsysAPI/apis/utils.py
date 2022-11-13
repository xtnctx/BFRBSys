import re, os

def hex_to_c_array(hex_data) -> str:
    c_str = ''

    # Declare C variable
    c_str += 'unsigned char model[] = {'
    hex_array = []

    for i, val in enumerate(hex_data):
        # Construct string from hex
        hex_str = format(val, '#04x')

        # Add formatting so each line stays within 80 characters
        if (i + 1) < len(hex_data):
            hex_str += ','
        if (i + 1) % 12 == 0:
            hex_str += '\n'
        hex_array.append(hex_str)

    # Add closing brace
    c_str += '\n ' + format(' '.join(hex_array)) + '\n};'

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
