package com.asiainfo.dacp.dp.agent;

import java.util.Vector;

public class TestArray {

	public static void main(String[] args) {
		Vector<String>  array= new Vector<String>();
		array.add("1");
		array.add("1");
		array.add("1");
		array.add("1");
		array.add("1");
		array.add("1");
		array.add("1");
		array.add("1");
		String res = array.toString();
		res = res.substring(1, res.length()-1);
		System.out.println(array.toString());
		System.out.println(res);
	}

}
