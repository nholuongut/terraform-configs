#!/usr/bin/env ruby

require 'json'
require 'aws-sdk-s3'

abort "Must set AWS_ALTERNATE_ACCOUNTS" if !ENV.has_key?('AWS_ALTERNATE_ACCOUNTS')
abort "Must set ORG" if !ENV.has_key?('ORG')

%w(tf-state-store satellite-artifacts).each do |target|
  bucket_policy = { 
    Version: '2012-10-17',
    Statement: [
      {
        Sid: "List Bucket",
        Effect: "Allow",
        Principal: { AWS: ENV.fetch('AWS_ALTERNATE_ACCOUNTS', '').split(',').collect { |a| "arn:aws:iam::#{a}:root" } },
        Action: [
          "s3:ListBucket"
        ],
        Resource: "arn:aws:s3:::#{ENV['ORG']}-#{target}"
      },
      {
        Sid: "Terraform workspace state store access",
        Effect: "Allow",
        Principal: { AWS: ENV['AWS_ALTERNATE_ACCOUNTS'].split(',').collect { |a| "arn:aws:iam::#{a}:root" } },
        Action: "s3:*",
        Resource: "arn:aws:s3:::#{ENV['ORG']}-#{target}/env:/*"
      },
      {
        Sid: "Global read access",
        Effect: "Allow",
        Principal: { AWS: ENV['AWS_ALTERNATE_ACCOUNTS'].split(',').collect { |a| "arn:aws:iam::#{a}:root" } },
        Action: "s3:GetObject",
        Resource: "arn:aws:s3:::#{ENV['ORG']}-#{target}/*"
      }
    ]
  }
  
  s3 = Aws::S3::Client.new
  if s3.list_buckets.buckets.collect { |b| b.name if b.name == "#{ENV['ORG']}-#{target}" }.compact.empty?
    resp = s3.create_bucket( { bucket: "#{ENV['ORG']}-#{target}", acl: 'private' })
    bucket = resp.location.sub('/', '')
  
    vers = Aws::S3::BucketVersioning.new(bucket, {client: s3})
    vers.put({ versioning_configuration: { status: "Enabled" } })
  
    puts JSON.pretty_generate(bucket_policy)
    policy = Aws::S3::BucketPolicy.new(bucket, {client: s3})
    policy.put({ confirm_remove_self_bucket_access: false, policy: JSON.generate(bucket_policy) })
  
    tagging = Aws::S3::BucketTagging.new(bucket, {client: s3})
    tagging.put({ tagging: { tag_set: [ { key: 'Environment', value: 'shared' } ] } })
  end
end
