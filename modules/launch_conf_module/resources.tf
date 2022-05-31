resource "aws_launch_configuration" "launch_conf" {
  name          = "tf_jmi_launc_conf"
  image_id      = data.aws_ami.amazon.id
  instance_type = "t2.micro"
  user_data = data.local_file.user_data.content


 lifecycle {
    create_before_destroy = true
  }
}