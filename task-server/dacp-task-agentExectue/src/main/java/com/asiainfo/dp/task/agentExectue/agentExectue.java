package com.asiainfo.dp.task.agentExectue;

import java.io.BufferedReader;
import java.io.BufferedWriter;
import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.io.InputStreamReader;
import java.lang.reflect.Field;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.util.StringUtils;

import com.google.gson.Gson;
import com.sun.jna.Platform;
import com.sun.jna.Pointer;
import com.sun.jna.platform.win32.Kernel32;
import com.sun.jna.platform.win32.WinNT.HANDLE;

public class agentExectue {
	private static String myid;
	private static String cmdline;
	private static String agendCode;
	private static String logPath;
	private static String taskRunLogPath=".cache/";
	public static Logger LOG = LoggerFactory.getLogger(agentExectue.class);
	public static void main(String[] args) {
		if(args==null||args.length<4){
			LOG.error("参数错误");
			return ;
		}
		myid=args[0];
		cmdline=args[1];
		agendCode=args[2];
		logPath=args[3];
		Task  task = new Task();
		task.setAgentCode(agendCode);
		task.setCmdLine(cmdline);
		try {
			boolean taskRunLogflag = mkDir(taskRunLogPath+agendCode);
			boolean mkdirLogPath=mkDir(logPath);
			if(!taskRunLogflag){
				LOG.error("缓存目录创建失败!");
				return;
			}
			if(!mkdirLogPath){
				LOG.error("任务日志目录创建失败!");
				return;
			}
			int returnCode =-1;
			cmdline =cmdline.replaceAll(",", " ");
			Gson gson = new Gson();
			boolean flag =false;
			System.out.println(cmdline);
			long  startTime= System.currentTimeMillis();
			Process  process =  null;
			int pid =-1;
			try {
				task.setRunMsg(returnCode==-1?CacheType.FinishStatus.RUN_RUNING:"");
				task.setPid(String.valueOf(pid));
				task.setSendFlag(CacheType.FinishStatus.UNSEND);
				task.setStartTime(String.valueOf(startTime));
				task.setSeqno(myid);
				task.setCheckCount("0");
				task.setExitValue("-1");
				createRunLog(taskRunLogPath+agendCode,myid+"",gson.toJson(task).toString());
				
				process=createProcess(logPath+"/"+myid+".log",cmdline.split(" "));
				pid= getPid(process);
				task.setRunMsg(returnCode==-1?CacheType.FinishStatus.RUN_RUNING:"");
				task.setPid(String.valueOf(pid));
				task.setSendFlag(CacheType.FinishStatus.UNSEND);
				task.setStartTime(String.valueOf(startTime));
				task.setSeqno(myid);
				task.setCheckCount("0");
				task.setExitValue("-1");
			} catch (Exception e) {
				task.setRunMsg(CacheType.FinishStatus.RUN_INTERRUPTION);
				task.setPid(String.valueOf(pid));
				task.setSendFlag(CacheType.FinishStatus.UNSEND);
				task.setStartTime(String.valueOf(startTime));
				task.setSeqno(myid);
				task.setCheckCount("0");
				task.setExitValue("-1");
				deleteOldFile(taskRunLogPath+agendCode+"/"+myid);
				flag= createRunLog(taskRunLogPath+agendCode,myid+"",gson.toJson(task).toString());
				return ;
			}
			deleteOldFile(taskRunLogPath+agendCode+"/"+myid);
			flag= createRunLog(taskRunLogPath+agendCode,myid+"",gson.toJson(task).toString());
			process.waitFor();
			deleteOldFile(taskRunLogPath+agendCode+"/"+myid);
			long  endTime = System.currentTimeMillis();
			returnCode= process.exitValue();
			task.setRunMsg(returnCode==0?CacheType.FinishStatus.RUN_SUCCESS:CacheType.FinishStatus.RUN_ERROR);
			task.setExitValue(String.valueOf(returnCode));
			task.setEndTime(String.valueOf(endTime));
			flag= createRunLog(taskRunLogPath+agendCode,myid+"",gson.toJson(task).toString());
			if(!flag){
				LOG.error("写入运行日志失败");
				return;
			}
			System.exit(returnCode);
		} catch (Exception e) {
			e.printStackTrace();
		}
	}
	private static boolean createRunLog(String path, String fileName,String log) {
		BufferedWriter  writer  = null;
		try {
			File  f = new File(path,fileName);
			if(f.exists()){
				f.createNewFile();
			}
			writer= new BufferedWriter(new FileWriter(f));
			System.out.println("写入文件");
			writer.write(log);
			writer.flush();
			return true;
		} catch (Exception e) {
			return false;
		}finally {
			if (writer!=null){
				try {
					writer.close();
				} catch (IOException e) {
					e.printStackTrace();
				}
			}
		}
			
	}
	private static boolean mkDir(String path) {
		try {
			File  f = new File(path);
			if(!f.exists()&&!f.isDirectory()){
				f.mkdirs();
			}
			return true;
		} catch (Exception e) {
			return false;
		}
	}
	
	public static Process createProcess(final String logFile, String[] args) {
		Process process = null;
		ProcessBuilder builder = new ProcessBuilder();
		builder.command(args);
		// 重定向输入输出
		builder.redirectErrorStream(true);
		// 检测日志文件路径
		try {
			
			process = builder.start();
			if (!StringUtils.isEmpty(logFile)) {
				deleteOldFile(logFile);
				final Process _process = process;
				new Thread(new Runnable() {
					public void run() {
						String line = null;
						BufferedWriter bw = null;
						BufferedReader out = new BufferedReader(
								new InputStreamReader(_process.getInputStream()));
						try {
							bw = new BufferedWriter(new FileWriter(logFile,
									true));
							while ((line = out.readLine()) != null) {
								bw.append(line);
								bw.newLine();
								bw.flush();
							}
						} catch (Exception e) {
//							writeLog(logFile, getExceptionDetail(e));
						} finally {
							try {
								out.close();
								bw.close();
							} catch (Exception e) {
							}
						}
					}
				}).start();
			}
		} catch (Exception e) {
			String error = String.format("创建进程[%s}]失败，错误原因：[%s]", args,
					getExceptionDetail(e));
//			writeLog(logFile, error);
		}
		return process;
	}
	
	private static void deleteOldFile(String logFile) {
		File file= new File(logFile);
		file.delete();
	}
	
	
	public static int getPid(Process process) {
		try {

			if (process == null) {
				return -1;
			}
			Field field = null;
			if (Platform.isWindows()) {
				try {
					field = process.getClass().getDeclaredField("handle");
					field.setAccessible(true);
					long _handle = field.getLong(process);
					HANDLE handle = new HANDLE();
					handle.setPointer(Pointer.createConstant(_handle));
					int pid = Kernel32.INSTANCE.GetProcessId(handle);
					return pid;
				} catch (Exception ex) {
					ex.printStackTrace();
				}
			} else if (Platform.isMac()) {

			} else {
				try {
					field = process.getClass().getDeclaredField("pid");
					field.setAccessible(true);
					int pid = (Integer) field.get(process);
					return pid;
				} catch (Exception ex) {
				}
			}
		} catch (Exception ex) {
			ex.printStackTrace();
		}
		return -1;
	}
	private static String getExceptionDetail(Exception e) {
		StringBuffer msg = new StringBuffer("null");
		if (e != null) {
			msg = new StringBuffer("");
			String message = e.toString();
			int length = e.getStackTrace().length;
			if (length > 0) {
				msg.append(message + "\n");
				for (int i = 0; i < length; i++) {
					msg.append("\t" + e.getStackTrace()[i] + "\n");
				}
			} else {
				msg.append(message);
			}

		}
		return msg.toString();
	}

}
