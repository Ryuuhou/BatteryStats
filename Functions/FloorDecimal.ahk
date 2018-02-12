FloorDecimal(num) {

  num:=Floor(num*100)
  SetFormat Float, 0.2
  return num/100

}