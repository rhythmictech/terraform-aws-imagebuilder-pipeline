# downstream build example
This example shows how to link two builds together in a golden image model.

This build pipeline looks each Monday at 00:00 GMT for a new Amazon Linux 2 AMI. If found, it will kick off a build that includes an ansible playbook and a basic reboot test after the role is applied.

The second build will run at 02:00 GMT _only if_ a new upstream build is found. It runs a different Ansible playbook. Both produce unique Image ARNs and AMIs that match the specified prefix pattern. (`base_image_2020*` and `app_image_2020*` respectively).
