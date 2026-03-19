# delete the objects
  aws s3 rm s3://mi-bucket-nombre --recursive

  # delete versions 
  aws s3api delete-objects \
    --bucket mi-bucket-nombre \
    --delete "$(aws s3api list-object-versions \
      --bucket mi-bucket-nombre \
      --query '{Objects: Versions[].{Key:Key,VersionId:VersionId}}' \
      --output json)"

  # delete markers
  aws s3api delete-objects \
    --bucket mi-bucket-nombre \
    --delete "$(aws s3api list-object-versions \
      --bucket mi-bucket-nombre \
      --query '{Objects: DeleteMarkers[].{Key:Key,VersionId:VersionId}}' \
      --output json)"


  terraform destroy