jam_belajar = []
jalan = True
while jalan :
    print ('\n=== STUDY TRACKER ===')
    print('1.tambah jam belajar')
    print('2.lihat total jam belajar') 
    print('3.keluar')
    pilihan = int(input('pilih menu : '))
    if pilihan == 1:
        jam = int(input('masukan jam belajar : '))
        jam_belajar.append(jam)
        print('data anda berhasil disimpan')
    elif pilihan == 2 :
        if len(jam_belajar) == 0:
            print('belum ada data belajar')
        else:
            total = sum(jam_belajar)
            print('total jam belajar:', total )
    elif pilihan == 3 :
        jalan = False
print('program selesai')