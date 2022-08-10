

credhub set -n /dev-bosh/dev-cf/blobstore_secret_access_key  -t value -v ${aws_secret_key_s3}
credhub set -n /dev-bosh/dev-cf/blobstore_access_key_id      -t value -v ${aws_access_key_s3}