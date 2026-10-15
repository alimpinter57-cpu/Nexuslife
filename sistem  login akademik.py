while jalan : True 
     print (' selamat datang di system akademi roudlotul muta abiddin ')
     data = input('masukan id kamu: ')
     print('id telah tersimpan')
     data_penyimpanan.append(data)
     print(data_penyimpanan)
     pilihan = input('mau keluar atau tetap disini. ya atau tidak')
     if pilihan.lower ==  'tidak':
         print(' okey')
     elif pilihan.lower == 'ya':
         jalan = false