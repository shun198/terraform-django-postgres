# ------------------------------
# デバッグ用に出力
# ------------------------------
output "db_host" {
  value = aws_db_instance.main.address
}