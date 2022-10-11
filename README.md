# stable-diffusion-webui-colab-script
## novel ai部署
新建colab笔记本，复制并执行以下代码即可
```shell
!git clone https://github.com/TIELIZI/stable-diffusion-webui-colab-script.git
!sh ./stable-diffusion-webui-colab-script/run_novel_ai.sh
```

## 模型下载
以上两行代码不包含模型文件下载，模型文件不存在时，会报 can't run without a checkpoint 错误<br>
可以先执行以下代码下载模型文件（通过torrent下载，可能需要1小时或更长），或者自行上传模型到目录 models/

```shell
!python -m pip install --upgrade pip setuptools wheel
!python -m pip install lbry-libtorrent
!wget https://raw.githubusercontent.com/TIELIZI/stable-diffusion-webui-colab-script/main/novelaileak.torrent
import shutil
import libtorrent as lt
import time
import datetime

ses = lt.session()
ses.listen_on(6881, 6891)

e = lt.bdecode(open("novelaileak.torrent", 'rb').read())
info = lt.torrent_info(e)
handle = ses.add_torrent(info, '/content/model/')
ses.start_dht()

begin = time.time()
print(datetime.datetime.now())
print("Starting", handle.name())

file_to_download=[
  "novelaileak/stableckpt/animevae.pt",
  "novelaileak/stableckpt/animefull-latest/model.ckpt",
  "novelaileak/stableckpt/modules/modules/aini.pt",
  "novelaileak/stableckpt/modules/modules/anime.pt",
  "novelaileak/stableckpt/modules/modules/anime_2.pt",
  "novelaileak/stableckpt/modules/modules/anime_3.pt",
  "novelaileak/stableckpt/modules/modules/furry.pt",
  "novelaileak/stableckpt/modules/modules/furry_2.pt",
  "novelaileak/stableckpt/modules/modules/furry_3.pt",
  "novelaileak/stableckpt/modules/modules/furry_kemono.pt",
  "novelaileak/stableckpt/modules/modules/furry_protogen.pt",
  "novelaileak/stableckpt/modules/modules/furry_scalie.pt",
  "novelaileak/stableckpt/modules/modules/furry_transformation.pt",
  "novelaileak/stableckpt/modules/modules/pony.pt"
]
info = handle.get_torrent_info()

for i in range(info.num_pieces()):
  handle.piece_priority(i,0)
file_index = 0
for file in info.files():
    if info.files().file_path(file_index) in file_to_download:
      print(info.files().file_path(file_index))
      pr = info.map_file(file_index, 0, 0)
      pr_next = info.map_file(file_index+1, 0, 0)
      for i in range(info.num_pieces()):
        if i in range(pr.piece, pr_next.piece):
          handle.piece_priority(i,7)
          
    file_index += 1

while (not handle.is_seed()):
    s = handle.status()
    state_str = ['queued', 'checking', 'downloading metadata', \
    'downloading', 'finished', 'seeding', 'allocating', 'checking fastresume']
    print('%.2f%% complete (down: %.1f kb/s up: %.1f kB/s peers: %d) %s' % \
            (s.progress * 100, s.download_rate / 1000, s.upload_rate / 1000, \
            s.num_peers, state_str[s.state]))
    if s.progress>=1:
        break
    time.sleep(1)

end = time.time()
print(handle.name(), "COMPLETE")

print("Elapsed Time: ",int((end-begin)//60),"min :", int((end-begin)%60), "sec")

print(datetime.datetime.now())

!mkdir -p /content/model/
!mv /content/model/novelaileak/stableckpt/animevae.pt /content/models/Stable-diffusion/final-pruned.vae.pt 
!mv /content/model/novelaileak/stableckpt/animefull-latest/model.ckpt /content/models/Stable-diffusion/final-pruned.ckpt
!mv /content/model/novelaileak/stableckpt/modules/modules/ /content/models/hypernetworks
```
