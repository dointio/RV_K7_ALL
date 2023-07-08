import sys
import os


def bin_to_coe(infile, outfile):
    binfile = open(infile, 'rb')
    binfile_content = binfile.read(os.path.getsize(infile)) #string!!!

    miffile = open(outfile, 'w')

    byte_content = bytearray(binfile_content)
    
    index = 0
    for b in  byte_content:
        
        # print(bin(b))
        # print(bin(b)[2:])
        # print(len(bin(b)[2:]))
        # print(bin(b)[2:].zfill(32))
        if index == 0:
            index = 1
            b0 = bin(b)[2:].zfill(8)
        elif index == 1:
            index = 2
            b1 = bin(b)[2:].zfill(8)
        elif index == 2:
            index = 3
            b2 = bin(b)[2:].zfill(8)
        else:
            index = 0
            b3 = bin(b)[2:].zfill(8)
            bytestr = b3+b2+b1+b0
            miffile.write(bytestr+'\n')
            # print(bytestr)


    binfile.close()
    miffile.close()


if __name__ == '__main__':
    if len(sys.argv) == 3:
        bin_to_coe(sys.argv[1], sys.argv[2])
    else:
        print('error!!')
