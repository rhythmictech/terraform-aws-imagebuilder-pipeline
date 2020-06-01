Resources:
  distConfig:
    Type: AWS::ImageBuilder::DistributionConfiguration
    Properties:
      Name: ${name} - Distribution Config
      %{~ if description != null ~}
      Description: ${description}
      %{~ endif ~}
      Distributions:
        %{~ for region in regions ~}
        - AmiDistributionConfiguration:
            Name: '${name} - AmiCopyConfiguration - {{ imagebuilder:buildDate }}'
            %{~ if description != null ~}
            Description: ${description}
            %{~ endif ~}
            AmiTags:
              ${ indent(14, chomp(yamlencode(tags))) }
            %{~ if shared_account_ids != null ~}
            LaunchPermissionConfiguration:
              UserIds:
                ${ indent(14, chomp(yamlencode(shared_account_ids))) }
            %{~ endif ~}
          %{~ if license_config_arns != null ~}
          LicenseConfigurationArns:
            ${ indent(12, chomp(yamlencode(license_config_arns)))}
          %{~ endif ~}
          Region: ${region}
        %{~ endfor ~}
      Tags:
        ${ indent(8, chomp(yamlencode(tags))) }
  infraConfig:
    Type: AWS::ImageBuilder::InfrastructureConfiguration
    Properties: 
      Name: ${name}-infrastructure-configuration
      %{~ if description != null ~}
      Description: ${description}
      %{~ endif ~}
      InstanceProfileName: ${instance_profile}
      %{~ if instance_types != null ~}
      InstanceTypes:
        ${ indent(8, chomp(yamlencode(instance_types))) }
      %{~ endif ~}
      %{~ if key_pair != null ~}
      KeyPair: ${key_pair}
      %{~ endif ~}
      %{~ if log_bucket != null ~}
      Logging:
        S3Logs:
          S3BucketName: ${log_bucket}
          %{~ if log_prefix != null ~}
          S3KeyPrefix: ${log_prefix}
          %{~ endif ~}
      %{~ endif ~}
      %{~ if security_group_ids != null ~}
      SecurityGroupIds:
        ${ indent(8, chomp(yamlencode(security_group_ids))) }
      %{~ endif ~}
      %{~ if sns_topic_arn != null ~}
      SnsTopicArn: ${sns_topic_arn}
      %{~ endif ~}
      %{~ if subnet != null ~}
      SubnetId: ${subnet}
      %{~ endif ~}
      Tags:
        ${ indent(8, chomp(yamlencode(tags))) }
      TerminateInstanceOnFailure: ${terminate_on_failure}
  imageBuildPipeline:
    Type: AWS::ImageBuilder::ImagePipeline
    Properties:
      Name: ${name}
      %{~ if description != null ~}
      Description: ${description}
      %{~ endif ~}
      DistributionConfigurationArn: !Ref "distConfig"
      ImageRecipeArn: ${recipe_arn}
      ImageTestsConfiguration:
        ${ indent(8, chomp(yamlencode(test_config))) }
      InfrastructureConfigurationArn: !Ref "infraConfig"
      Schedule:
        ${ indent(8, chomp(yamlencode(schedule))) }
      Status: ${status}
      Tags:
        ${ indent(8, chomp(yamlencode(tags))) }
Outputs:
  PipelineArn:
    Description: ARN of the created component
    Value: !Ref "imageBuildPipeline"
