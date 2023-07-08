import sys
import os


def bin_to_coe(infile, outfile):
    binfile = open(infile, 'rb')
    binfile_content = binfile.read(os.path.getsize(infile))

    coefile = open(outfile, 'w')

    coefile.write('memory_initialization_radix = 16;\nmemory_initialization_vector =\n')

    index = 0
    c1 = ""
    c2 = ""
    c3 = ""
    c4 = ""
    count = 0
    for b in  binfile_content:
        if index == 0:
            index = index + 1
            c1 = b.encode('hex')
            if len(c1) == 1:
                c1 = '0' + c1
        elif index == 1:
            index = index + 1
            c2 = b.encode('hex')
            if len(c2) == 1:
                c2 = '0' + c2
        elif index == 2:
            index = index + 1
            c3 = b.encode('hex')
            if len(c3) == 1:
                c3 = '0' + c3
        elif index == 3:
            index = 0
            count = count + 1
            c4 = b.encode('hex')
            if len(c4) == 1:
                c4 = '0' + c4
            if(count == os.path.getsize(infile)/4):
                coefile.write(c4+c3+c2+c1 + ';\n')
            else:
                coefile.write(c4+c3+c2+c1 + ',\n')

    binfile.close()
    coefile.close()


if __name__ == '__main__':
    if len(sys.argv) == 3:
        bin_to_coe(sys.argv[1], sys.argv[2])
    else:
        print('error!!')
