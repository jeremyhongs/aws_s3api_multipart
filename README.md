# Basic Concept
- __기본적으로 Amazon S3에 올릴 수 있는 Object max size는 5GB__
- __따라서 5GB보다 큰 object는 Multipart Upload를 이용해야 하며, 업로드 최대 사이즈는 5TB__
- Object size가 over 100MB의 경우, Multipart Upload 이용 할 것을 권장
- S3 Multipart download는 upload처럼 별도의 API가 존재하는 것이 아니고, API를 혼합해서 스크립트로 만들고 이를 활용해야 함 (s3md.sh 참고)
- 이외 작업 전 AWS configure를 조절하기 바람
  > max_concurrent_request / max_queue_size / multipart-threshold / multipart-chunksize

## Environment
- Windows10 + Dcoker + Ubuntu + AWS CLIv2
- Docker에서 exit하면 이미지에서 작업하는 환경 날라갈테니, 어느정도 base env 구축해두고 commit or compile로 이미지 만들어놓고 사용 할 것
- 그리고 Docker 실행 할 때, disk mount (-v) 할 것. (작업한 파일 갖고있기 위함)


## 1. AWS S3 Multipart Upload
- 업로드 따라해보기 URL : https://aws.amazon.com/ko/premiumsupport/knowledge-center/s3-multipart-upload-cli/
- __Multipart Upload API 활용시 이점__
```
- 최종 개체 크기를 알기 전에 업로드 시작 가능 (You can begin an upload before you know the final object size)
- 모든 네트워크 문제에서 신속하게 복구 가능 (Quick recovery from any network issues)
- 객체 업로드를 일시 중지 및 다시 시작 가능 (Pause and resume object uplaods)
```
- __Multipart Upload 제한__ : https://docs.aws.amazon.com/ko_kr/AmazonS3/latest/userguide/qfacts.html

### Test Environment
- Windows10 + Docker + Ubuntu + AWS CLIv2


#### Step flow (Linux 환경에 AWS CLI 설치 가정)
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



## 2. AWS S3 Multipart Download
- 다운로드 따라하기 URL : https://aws.amazon.com/ko/blogs/korea/amazon-s3-multi-part-dowload/
- 활용시 사용되는 API는 list-objects, get-object를 이용하게 되며 필요에 따라 argument를 익힐 수 있도록 할 것
- 스크립트를 나만의 것으로 만들어서 사용 하면 됨
- 해당 예제는 bucket을 기준으로 작성 되었고, 하위 object로 접근 하기 위한 방법을 알아두면 좋음

