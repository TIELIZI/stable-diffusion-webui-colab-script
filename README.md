# stable-diffusion-webui-colab-script
## 操作视频
https://www.bilibili.com/video/BV1UD4y1k7yh

## novel ai部署
新建colab笔记本，修改-笔记本设置选GPU，复制并执行以下代码即可
```shell
from google.colab import drive
drive.mount('/content/drive')
!git clone https://github.com/TIELIZI/stable-diffusion-webui-colab-script.git
!sh ./stable-diffusion-webui-colab-script/run_novel_ai.sh
```

## 模型下载
以上部署代码不包含模型文件下载，模型文件不存在时，会报 can't run without a checkpoint 错误<br>
解决方案：
1、google drive 共享文件
https://drive.google.com/drive/folders/1-4MNEGjBt-GtVQEOIoKpejn1Q63eN2dZ?usp=sharing
全选-右键添加快捷方式到云端硬盘-我的云端硬盘-新建models目录-选中models目录点击保存

2、执行以下代码，下载模型文件到 google drive 的 /models 目录（通过torrent下载，可能需要1小时或更长）<br>
google drive存在模型后，下次使用可不需要再次下载

```shell
from google.colab import drive
drive.mount('/content/drive')

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
handle = ses.add_torrent(info, '/content/')
ses.start_dht()

begin = time.time()
print(datetime.datetime.now())
print("Starting", handle.name())

file_to_download=[
  "novelaileak/stableckpt/animevae.pt",
  "novelaileak/stableckpt/animefull-final-pruned/model.ckpt",
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
        if i in range(pr.piece, pr_next.piece+1):
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

print("Moving model to Google Drive...")
!mkdir -p /content/drive/MyDrive/models/Stable-diffusion/
!mv /content/novelaileak/stableckpt/animevae.pt /content/drive/MyDrive/models/Stable-diffusion/final-pruned.vae.pt 
!mv /content/novelaileak/stableckpt/animefull-final-pruned/model.ckpt /content/drive/MyDrive/models/Stable-diffusion/final-pruned.ckpt
!mv /content/novelaileak/stableckpt/modules/modules/ /content/drive/MyDrive/models/hypernetworks
print("Success!")
```
