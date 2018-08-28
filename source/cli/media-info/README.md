# dc-media-info

> A simple helper to extract info from movie files

## TL;DR

`dc-media-info -s somefile.mp4`

```
{
  "file": "somefile.mp4",
  "size": "4683785287",
  "container": "mov,mp4,m4a,3gp,3g2,mj2",
  "fast": "false",
  "duration": 6241,
  "video": [
    {
      "id": 0,
      "codec": "h264",
      "description": "H.264 / AVC / MPEG-4 AVC / MPEG-4 part 10",
      "width": 1280,
      "heaight": 544
    }
  ],
  "audio": [
    {
      "id": 1,
      "codec": "dts",
      "description": "DCA (DTS Coherent Acoustics)",
      "language": "fre"
    }
  ],
  "subtitles": [
    {
      "id": 2,
      "codec": "mov_text",
      "description": "MOV text",
      "language": "eng"
    }
  ],
  "other": []
}
```

# Have fun

List all video codecs in all files

```
find some_folder -type f -print0 | xargs -0 -I '{}' ./debug media-info -s '{}' | jq 'select(.video != null) | .video[].codec + ": " + .video[].description'
```
