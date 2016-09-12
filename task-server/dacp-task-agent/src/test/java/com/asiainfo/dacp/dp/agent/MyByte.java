package com.asiainfo.dacp.dp.agent;
public class MyByte {
 
    /**
     * 字符串转换成十六进制字符串
     * 
     * @param String
     *            str 待转换的ASCII字符串
     * @return String 每个Byte之间空格分隔，如: [61 6C 6B]
     */
    public static String str2HexStr(String str) {
 
        char[] chars = "0123456789ABCDEF".toCharArray();
        StringBuilder sb = new StringBuilder("");
        byte[] bs = str.getBytes();
        int bit;
 
        for (int i = 0; i < bs.length; i++) {
            bit = (bs[i] & 0x0f0) >> 4;
            sb.append(chars[bit]);
            bit = bs[i] & 0x0f;
            sb.append(chars[bit]);
            sb.append(' ');
        }
        return sb.toString().trim();
    }
 
    /**
     * 十六进制转换字符串
     * 
     * @param String
     *            str Byte字符串(Byte之间无分隔符 如:[616C6B])
     * @return String 对应的字符串
     */
    public static String hexStr2Str(String hexStr) {
        String str = "0123456789ABCDEF";
        char[] hexs = hexStr.toCharArray();
        byte[] bytes = new byte[hexStr.length() / 2];
        int n;
 
        for (int i = 0; i < bytes.length; i++) {
            n = str.indexOf(hexs[2 * i]) * 16;
            n += str.indexOf(hexs[2 * i + 1]);
            bytes[i] = (byte) (n & 0xff);
        }
        return new String(bytes);
    }
 
    /**
     * String的字符串转换成unicode的String
     * 
     * @param String
     *            strText 全角字符串
     * @return String 每个unicode之间无分隔符
     * @throws Exception
     */
    public static String strToUnicode(String strText) throws Exception {
        char c;
        StringBuilder str = new StringBuilder();
        int intAsc;
        String strHex;
        for (int i = 0; i < strText.length(); i++) {
            c = strText.charAt(i);
            intAsc = (int) c;
            strHex = Integer.toHexString(intAsc);
            if (intAsc > 128)
                str.append("\\u" + strHex);
            else
                // 低位在前面补00
                str.append("\\u00" + strHex);
        }
        return str.toString();
    }
 
    /**
     * unicode的String转换成String的字符串
     * 
     * @param String
     *            hex 16进制值字符串 （一个unicode为2byte）
     * @return String 全角字符串
     */
    public static String unicodeToString(String hex) {
        int t = hex.length() / 6;
        StringBuilder str = new StringBuilder();
        for (int i = 0; i < t; i++) {
            String s = hex.substring(i * 6, (i + 1) * 6);
            // 高位需要补上00再转
            String s1 = s.substring(2, 4) + "00";
            // 低位直接转
            String s2 = s.substring(4);
            // 将16进制的string转为int
            int n = Integer.valueOf(s1, 16) + Integer.valueOf(s2, 16);
            // 将int转换为字符
            char[] chars = Character.toChars(n);
            str.append(new String(chars));
        }
        return str.toString();
    }
 
    /**
     * 合并两个byte数组
     * 
     * @param pByteA
     * @param pByteB
     * @return
     */
    public static byte[] getMergeBytes(byte[] pByteA, byte[] pByteB) {
        int aCount = pByteA.length;
        int bCount = pByteB.length;
        byte[] b = new byte[aCount + bCount];
        for (int i = 0; i < aCount; i++) {
            b[i] = pByteA[i];
        }
        for (int i = 0; i < bCount; i++) {
            b[aCount + i] = pByteB[i];
        }
        return b;
    }
 
    /**
     * 截取byte数据
     * 
     * @param b
     *            是byte数组
     * @param j
     *            是大小
     * @return
     */
    public static byte[] cutOutByte(byte[] b, int j) {
        if (b.length == 0 || j == 0) {
            return null;
        }
        byte[] tmp = new byte[j];
        for (int i = 0; i < j; i++) {
            tmp[i] = b[i];
        }
        return tmp;
    }
 
    /**
     * 16进制字符串转换byte数组
     * 
     * @param hexstr
     *            String 16进制字符串
     * @return byte[] byte数组
     */
    public static byte[] HexString2Bytes(String hexstr) {
        byte[] b = new byte[hexstr.length() / 2];
        int j = 0;
        for (int i = 0; i < b.length; i++) {
            char c0 = hexstr.charAt(j++);
            char c1 = hexstr.charAt(j++);
            b[i] = (byte) ((parse(c0) << 4) | parse(c1));
        }
        return b;
    }
 
    private static int parse(char c) {
        if (c >= 'a')
            return (c - 'a' + 10) & 0x0f;
        if (c >= 'A')
            return (c - 'A' + 10) & 0x0f;
        return (c - '0') & 0x0f;
    }
 
    /**
     * byte转换为十六进制字符串，如果为9以内的，用0补齐
     * 
     * @param b
     * @return
     */
    public static String byteToHexString(byte b) {
        String stmp = Integer.toHexString(b & 0xFF);
        stmp = (stmp.length() == 1) ? "0" + stmp : stmp;
        return stmp.toUpperCase();
    }
 
    /**
     * 将byte转换为int
     * 
     * @param b
     * @return
     */
    public static int byteToInt(byte b) {
        return Integer.valueOf(b);
    }
 
    /**
     * bytes转换成十六进制字符串
     * 
     * @param byte[] b byte数组
     * @return String 每个Byte值之间空格分隔
     */
    public static String byteToHexString(byte[] b) {
        String stmp = "";
        StringBuilder sb = new StringBuilder("");
        for (byte c : b) {
            stmp = Integer.toHexString(c & 0xFF);// 与预算，去掉byte转int带来的补位
            sb.append((stmp.length() == 1) ? "0" + stmp : stmp);// 是一位的话填充零
            sb.append(" ");// 每位数据用空格分隔
        }
        return sb.toString().toUpperCase().trim();// 变换大写，并去除首尾空格
    }
 
    public static long HexString2Long(String hexstr) {
        long sum=0;
        int length=hexstr.length();
        for (int i = 0; i < length; i++) {
            sum+=parse(hexstr.charAt(i))*Math.pow(16,length-i-1);
        }
        return sum;
    }
}