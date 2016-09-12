package com.asiainfo.dacp.dp.server.scheduler.utils;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.ObjectInputStream;
import java.io.ObjectOutputStream;

import org.apache.zookeeper.WatchedEvent;
import org.apache.zookeeper.Watcher;
import org.apache.zookeeper.ZooKeeper;
import org.junit.runner.RunWith;
import org.springframework.test.context.ContextConfiguration;
import org.springframework.test.context.junit4.SpringJUnit4ClassRunner;
@RunWith(SpringJUnit4ClassRunner.class)
@ContextConfiguration(locations = "classpath:conf/*.xml")
//@ContextConfiguration(locations = "file:conf/*.xml")
public class IOTest {
	
	
	public static void main(String[] args) throws IOException, ClassNotFoundException {
		
		try {
			ObjectOutputStream oo = null;
			ObjectInputStream oi = null;
			ByteArrayOutputStream bo = new ByteArrayOutputStream();
			oo = new ObjectOutputStream(bo);
		File file=new File("G:/system.properties");
		oo.writeObject(file);
		byte[] b=bo.toByteArray();
		
		ByteArrayInputStream bi=new ByteArrayInputStream(b);
		oi=new ObjectInputStream(bi);
		File f=(File) oi.readObject();
		} catch (FileNotFoundException e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}
	}
}