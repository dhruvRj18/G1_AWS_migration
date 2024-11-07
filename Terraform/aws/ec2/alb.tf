resource "aws_lb" "front_end_alb" {
  name               = "front-end-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = [aws_subnet.public.id]
}

resource "aws_lb_target_group" "front_end_tg" {
  name     = "front-end-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = aws_vpc.main.id
}

resource "aws_lb_listener" "front_end_listener" {
  load_balancer_arn = aws_lb.front_end_alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front_end_tg.arn
  }
}

resource "aws_lb_target_group_attachment" "front_end_tg_attachment" {
  target_group_arn = aws_lb_target_group.front_end_tg.arn
  target_id        = aws_instance.front_end.id
  port             = 80
}
