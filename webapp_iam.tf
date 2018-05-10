data "template_file" "webapp_policy" {
  template = "${file("templates/webapp_role_policy.json")}"
}

resource "aws_iam_role" "webapp" {
  name = "role_webapp"
  path = "/webapp/"
  assume_role_policy = "${file("templates/role.json")}"
}

resource "aws_iam_instance_profile" "webapp" {
  name = "role_webapp"
  role = "${aws_iam_role.webapp.name}"
}

resource "aws_iam_role_policy" "webapp" {
  name = "role_webapp"
  role = "${aws_iam_role.webapp.name}"
  policy = "${data.template_file.webapp_policy.rendered}"
}
