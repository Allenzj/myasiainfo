package com.asiainfo.dacp.dp.server.scheduler.utils;

import java.util.ArrayList;
import java.util.List;
import java.util.Random;

import com.asiainfo.dacp.dp.server.scheduler.sort.DpSorter;
import com.asiainfo.dacp.dp.server.scheduler.sort.SchedulePrioritySorter;

public class SortTest {
	public static class Point {
		private String x;
		private int y;
		public String getX() {
			return x;
		}
		public void setX(String x) {
			this.x = x;
		}
		public int getY() {
			return y;
		}
		public void setY(int y) {
			this.y = y;
		}
		public Point(String x, int y) {
			super();
			this.x = x;
			this.y = y;
		}
		public String toString(){
			return "["+this.x+","+this.y+"]";
		}
	}
	public static void main(String[] args){
		 Random rand = new Random();
		List<Object> pointList = new  ArrayList<Object>();
		pointList.add( new Point("xtc", (rand.nextInt(1111)+1)));
		pointList.add( new Point("wyb", (rand.nextInt(1111)+1)));
		pointList.add( new Point("wyb", (rand.nextInt(1111)+1)));
		pointList.add( new Point("xtc", (rand.nextInt(1111)+1)));
		pointList.add( new Point("wyb", (rand.nextInt(1111)+1)));
		pointList.add( new Point("xtc", (rand.nextInt(1111)+1)));
		pointList.add( new Point("wyb", (rand.nextInt(1111)+1)));
		pointList.add( new Point("xtc", (rand.nextInt(1111)+1)));
		pointList.add( new Point("xct", (rand.nextInt(1111)+1)));
		pointList.add( new Point("wyb", (rand.nextInt(1111)+1)));
		pointList.add( new Point("xtc", (rand.nextInt(1111)+1)));
		pointList.add( new Point("wyb", (rand.nextInt(1111)+1)));
		pointList.add( new Point("xct", (rand.nextInt(1111)+1)));
		for(Object obj: pointList){
			System.out.println(obj.toString());
		}
		System.out.println();
		DpSorter sorter = new SchedulePrioritySorter();
		/*
		sorter.sort(pointList, "x", DpSorter.DESC);
		for(Object obj: pointList){
			System.out.println(obj.toString());
		}
		System.out.println();
		sorter.sort(pointList, "y", DpSorter.DESC);
		for(Object obj: pointList){
			System.out.println(obj.toString());
		}*/
		sorter.groupSort(pointList, "x", "y", DpSorter.ASC, DpSorter.DESC);
		for(Object obj: pointList){
			System.out.println(obj.toString());
		}
		Object str = null;
		System.out.println((String) str);
	}
}
