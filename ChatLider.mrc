; =======================================================
;  ChatLider Network - Kararlı Kurumsal Dağıtım v3.5
; =======================================================

; --- ChatLider Sıkı Flood/Repeat Koruması ---
on @*:TEXT:*:#: {
  if ($nick == $me) { return }
  if ($1- == %lastmsg. $+ $nick) {
    inc %repeat.count. $+ $nick
    if (%repeat.count. $+ $nick >= 3) {
      mode $chan +b $nick
      kick $chan $nick Mesaj tekrarı (spam) yaptığınız için uzaklaştırıldınız.
      unset %repeat.count. $+ $nick
    }

  }
  else {
    set -u5 %lastmsg. $+ $nick $1-
    set -u10 %repeat.count. $+ $nick 1
  }
} 

; --- Giriş Paneli ---
dialog cl_giris {
  title "ChatLider Resmi Giriş Paneli"
  size -1 -1 220 160
  option dbu
  box " ChatLider Network Kullanıcı Girişi ", 1, 10 5 200 145
  text "Kullanıcı Adı (Nick):", 2, 20 20 60 10
  edit "", 3, 85 18 115 12, autohs
  text "Rumuz Şifreniz:", 4, 20 38 60 10
  edit "", 5, 85 36 115 12, pass autohs
  text "Yönetici (Oper) Şifresi:", 6, 20 56 60 10
  edit "", 7, 85 54 115 12, pass autohs
  button "Sistemi Başlat ve Bağlan", 8, 20 75 180 22, default
  button "Yeni Kayıt Oluştur", 9, 20 102 180 15
  text "Durum: ChatLider sistem ayarları yüklendi.", 10, 15 125 190 20, center
}

; --- Özel Ayar Paneli ---
dialog cl_ayarlar {
  title "ChatLider - Özel Yönetim ve Ayar Paneli"
  size -1 -1 240 190
  option dbu
  box " Sunucu ve Kanal Ayarları ", 1, 5 5 230 175
  text "Otomatik Giriş Yapılacak Genel Kanallar:", 2, 15 20 180 10
  edit "", 3, 15 32 210 12, autohs
  text "Yönetici (Oper) Giriş Kanalları:", 4, 15 50 180 10
  edit "", 5, 15 62 210 12, autohs
  text "Özel DJ Kanalı Adı:", 6, 15 80 100 10
  edit "", 7, 15 92 100 12, autohs
  text "Aktif DJ Listesi (Boşluk bırakarak yazın):", 8, 15 110 200 10
  edit "", 9, 15 120 210 12, autohs
  button "Tüm Ayarları Kaydet ve Uygula", 10, 15 145 210 25, default
}

on *:start: {
  titlebar ChatLider Network - Resmi Script Dağıtımı
  disconnect
  .timer 1 1 dialog -m cl_giris cl_giris
}

on *:dialog:cl_giris:sclick:*: {
  if ($did == 8) {
    if ($did(3) == $null || $did(5) == $null) { did -r cl_giris 10 | did -a cl_giris 10 Hata: Rumuz ve Şifre alanları boş bırakılamaz! | halt }
    set %oper_sifresi $did(7)
    nick $did(3)
    server 127.0.0.1 6667
    .timer 1 2 msg NickServ identify $did(5)
    dialog -c cl_giris
  }
  if ($did == 9) { nick $did(3) | server 127.0.0.1 6667 | .timer 1 2 msg NickServ register $did(5) $did(3) $+ @chatlider.com | dialog -c cl_giris }
}

on *:connect: {
  if (%cl_genel_kanallar == $null) { set %cl_genel_kanallar #Sohbet,#Radyo,#Oyun,#Muhabbet }
  if (%cl_yonetim_kanallar == $null) { set %cl_yonetim_kanallar #Log,#Yönetim,#Oper,#Admin }
  if (%cl_dj_kanali == $null) { set %cl_dj_kanali #DJ }
  if (%oper_sifresi != $null) { .timer 1 1.5 oper $me %oper_sifresi }
  .timer_joincs 1 2 join %cl_genel_kanallar
  if ($istok(%cl_dj_listesi,$me,32)) { .timer_joindj 1 2 join %cl_dj_kanali }
}

raw 381:*: {
  echo -a  4[ChatLider Güvenlik]  Büyük Yöneticisi Onaylandı!
  join %cl_yonetim_kanallar
  .timer 1 2 KurucuYetkiAyarla
  unset %oper_sifresi
}

alias KurucuYetkiAyarla {
  var %i = 1
  while ($chan(%i)) {
    mode $chan(%i) +o $me
    inc %i
  }
}

on *:join:#: {
  if ($nick == $me) {
    if ($isoper) { .timer 1 1 mode # +o $me }
  }
}

; --- SAĞ TIK MENÜSÜ ---
menu channel,nicklist {
  ChatLider Yönetim Paneli
  .Script Ayarlarını Aç : dialog -m cl_ayarlar cl_ayarlar
  -
  .Yöneticilik Yetkisi Ver (@) : mode # +o $1
  .Yöneticilik Yetkisi Al (-o) : mode # -o $1
  .Söz Hakkı Ver (+v) : mode # +v $1
  .Söz Hakkı Al (-v) : mode # -v $1
  -
  .Seçili Kişiyi DJ Listesine Ekle : set %cl_dj_listesi %cl_dj_listesi $1 | echo -a  4[ChatLider] $1  DJ listesine eklendi.
  .Seçili Kişiyi DJ Listesinden Sil : set %cl_dj_listesi $remtok(%cl_dj_listesi,$1,1,32) | echo -a  4[ChatLider] $1  DJ listesinden çıkarıldı.
}

on *:dialog:cl_ayarlar:init:*: {
  did -a cl_ayarlar 3 %cl_genel_kanallar
  did -a cl_ayarlar 5 %cl_yonetim_kanallar
  did -a cl_ayarlar 7 %cl_dj_kanali
  did -a cl_ayarlar 9 %cl_dj_listesi
}

on *:dialog:cl_ayarlar:sclick:10: {
  set %cl_genel_kanallar $did(3)
  set %cl_yonetim_kanallar $did(5)
  set %cl_dj_kanali $did(7)
  set %cl_dj_listesi $did(9)
  echo -a  4[ChatLider]  Tüm ayarlar kendi scriptinize başarıyla kaydedildi!
  dialog -c cl_ayarlar
} 
