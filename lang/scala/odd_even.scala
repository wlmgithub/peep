// http://prezi.com/ewvgkgw5pgim/scala-for-java-programmers/
//
object Partition {
  def main(args:Array[String]) : Unit = {
    val values = (1 to 10 ).toList
    val (odds, evens) = values.partition(_ % 2 == 0)
    println("odds: " + odds.toString)
    println("evens: " + evens.toString)
  }
}

Partition.main(args)
