# AWS S3 Multipart Upload
- 업로드 따라해보기 URL : https://aws.amazon.com/ko/premiumsupport/knowledge-center/s3-multipart-upload-cli/
- __Multipart Upload API 활용시 이점__
```
- 최종 개체 크기를 알기 전에 업로드 시작 가능 (You can begin an upload before you know the final object size)
- 모든 네트워크 문제에서 신속하게 복구 가능 (Quick recovery from any network issues)
- 객체 업로드를 일시 중지 및 다시 시작 가능 (Pause and resume object uplaods)
```
- __Multipart Upload 제한__ : https://docs.aws.amazon.com/ko_kr/AmazonS3/latest/userguide/qfacts.html

## Test Environment
- Docker + Ubuntu + AWS CLIv2
- docker run -it -v __SOURCE_MOUNTPATH__:__TARGET_MOUNTPATH__ __OS-DOCKERIMAGE:TAG__

### Step flow (Linux 환경에 AWS CLI 설치 가정)
- 무결성 체크에 필요한 md5 key 생성 (refer : https://aws.amazon.com/ko/premiumsupport/knowledge-center/data-integrity-s3/)
- 큰 파일을 split 명령어로 쪼개 둘 것 (refer : https://jhnyang.tistory.com/209)
- 쪼개어진 파일에 대한 MD5 key 생성 할 것 (openssl)
```
openssl md5 -binary FILE-PATH+FILE-NAME | base64
```
- ETag & VersionID 가져오기
```
aws s3api put-object --bucket _BUCKETNAME_ --key _ORIGINFILENAME_ --body _FILEPATH_ --content-md5 _MD5KEYVALUE_
```
- Split file upload (repeat)
```
aws s3api upload-part --bucket _BUCKETNAME_ --key _ORGINFILENAME_ --part-numer _COUNTNUMER_ --body _FILEPATH_ --uploadid _UPLOADIDVALUE_ --content-md5 _MD5KEYVALUE_
- part-number : split된 파일 수 (start with : 1)
- ETag 정보 가져올 것
```
- Upload 완료 후
```
aws s3api list-parts --bucket _BUCKETNAME_ --key _ORIGINFILENAME_ --upload-id _UPLOADIDVALUE_
- Upload된 전체 파일 리스트
```
- ETage 정보를 이용하여 json 파일 생성 (예,fileparts.json)
- Multi-part Upload Complete
```
aws s3api complete-multipart-upload --multipart-upload _JSONFILEPATH_ --bucket _BUCKETNAME_ --key _ORIGINFILENAME_ --upload-id _UPLOADIDVALUE_
- Output 정상적인지 확인
```
- S3 업로드 파일 확인


# AWS S3 Multipart Download
- 다운로드 따라하기 URL : https://aws.amazon.com/ko/blogs/korea/amazon-s3-multi-part-dowload/
- URL 내용처럼, Upload처럼 별도의 API는 없음
- URL에 있는 s3md.sh을 사용하면 됨
- URL에 써있는 예제는 Bucket 기준으로 작성 되었고, 하위 객체로 접근하기 위한 방법을 알아야 함 (아래 기재되어있으니 확인 하기 바람)
