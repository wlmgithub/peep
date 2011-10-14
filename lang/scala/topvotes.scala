// http://prezi.com/ewvgkgw5pgim/scala-for-java-programmers/

/*

 $ scala -version
 Scala code runner version 2.7.7.final -- Copyright 2002-2009, LAMP/EPFL

 */

import scala.collection.mutable.HashMap

def main(args:Array[String]) {

  val votes = List(
          ("Bob", 13),
          ("Ann", 3),
          ("Maria", 18)
  )

  val topVotes = votes.filter{
      case(name, num) => num > 5
  }

  val hm = new HashMap[String, Int]
  topVotes.foreach {
    case(name, num) => hm.put(name,num)
  }

  println(hm.toString)
  hm.foreach {
    case(name, num) => println(name + " => " + num)
  }

}

main(args)
