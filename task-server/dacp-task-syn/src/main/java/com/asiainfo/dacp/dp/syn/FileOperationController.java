package com.asiainfo.dacp.dp.syn;

import java.io.InputStream;
import java.io.OutputStream;
import java.io.Writer;
import java.sql.Blob;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.multipart.MultipartHttpServletRequest;

import com.asiainfo.dacp.jdbc.JdbcTemplate;
import com.google.gson.Gson;

@Controller
@RequestMapping("/fileOp")
public class FileOperationController {

	private JdbcTemplate jdbcTemplate;

	@RequestMapping("/download")
	public void fileDownload(HttpServletRequest request,HttpServletResponse response) throws Exception {
		request.setCharacterEncoding("utf-8");
		String xmlid = request.getParameter("xmlid");
		String fileName = request.getParameter("fileName");
		
		jdbcTemplate = new JdbcTemplate("METADB");
        Connection conn = jdbcTemplate.getDataSource().getConnection();
        
        byte[] data=null;//**将文件读入此字节数组  
        OutputStream os=null;  
        ResultSet rset=null;//**这里rs一定要用Oracle提供的  
        PreparedStatement pstmt=null;//**PreparedStatement用Oracle提供的  
        Blob blob=null;

        // 清空response  
        response.reset();
		response.setContentType("application/octet-stream;charset=utf-8");
		fileName = new String(fileName.getBytes("GB2312"), "ISO_8859_1");
		response.addHeader("Content-Disposition", "attachment;filename=" + fileName);
		
        try{ 
            String mysql="select report_file from bass1_data_quality_report where xml_id=? ";  
            pstmt=conn.prepareStatement(mysql);
            pstmt.setString(1,xmlid); 
            rset=pstmt.executeQuery();
            if(rset.next()){  
                blob = rset.getBlob(1);
                data= blob.getBytes(1L,(int)blob.length());//从BLOB取出字节流数据 
                conn.commit();
            }
            rset.close();
            os = response.getOutputStream();
            os.write(data);
            os.flush();  
            os.close();
        }catch(Exception e){ 
        	e.printStackTrace();
        }finally{  
            try {
                rset.close();  
            } catch (Exception e) {  
            	e.printStackTrace();
            }
            conn.close();
        }
	}
	
	@RequestMapping(value = "/upload")
	public void fileUpload(MultipartHttpServletRequest request,HttpServletResponse response) throws Exception {
		String xmlid = request.getParameter("XML_ID");
		String interCode = request.getParameter("INTER_CODE");
		String cycleId = request.getParameter("CYCLE_ID");
		String status = request.getParameter("CHECK_STATUS");
		String opinion = request.getParameter("CHECK_OPINION");
		String fileName = request.getParameter("REPORT_FILE");
		
		Writer out = response.getWriter();
		Map<String, String> res = new HashMap<String, String>();
		Gson gson = new Gson();
		
		jdbcTemplate = new JdbcTemplate("METADB");
        Connection conn = jdbcTemplate.getDataSource().getConnection();
		
		byte[] data=null;//**将文件读入此字节数组  
        //FileInputStream fis=null;
        OutputStream os=null;  
        ResultSet rset=null;//**这里rs一定要用Oracle提供的  
        PreparedStatement pstmt=null;//**PreparedStatement用Oracle提供的 
        Blob blob= null;
        
        try{
        	conn.setAutoCommit(false);
        	if(xmlid==null||xmlid.length()==0){
	            pstmt = conn.prepareStatement("insert into bass1_data_quality_report (inter_code,cycle_id,check_status,check_opinion,report_file,file_name) values(?,?,?,?,empty_blob(),?)");
	            pstmt.setString(1, interCode);  
	            pstmt.setString(2, cycleId); 
	            pstmt.setInt(3, Integer.parseInt(status)); 
	            pstmt.setString(4,opinion);
	            pstmt.setString(5,fileName);
	            pstmt.executeUpdate();
	            pstmt.close();
	        }
            
            pstmt = conn.prepareStatement("select check_status,check_opinion,report_file,file_name from bass1_data_quality_report where inter_code=? and cycle_id=?  for update");
            pstmt.setString(1, interCode);
            pstmt.setString(2,cycleId);
            rset = pstmt.executeQuery();
            if (rset.next()) {
                blob = rset.getBlob(3);
            }
            //File file = new File(path);
            //fis = new FileInputStream(file);
            List<MultipartFile> files = request.getFiles("file");
    		MultipartFile file = files.get(0);
    		InputStream fis = file.getInputStream();
    		
            pstmt = conn.prepareStatement("update bass1_data_quality_report set check_status=?,check_opinion=?,report_file=?,file_name=? where inter_code=? and cycle_id=? ");
            os = blob.setBinaryStream(1L);
            data = new byte[(int) fis.available()];
            fis.read(data);
            os.write(data);
            fis.close();
            os.close();
            pstmt.setInt(1,Integer.parseInt(status));
            pstmt.setString(2,opinion);
            pstmt.setBlob(3, blob);
            pstmt.setString(4,fileName);
            pstmt.setString(5,interCode);
            pstmt.setString(6,cycleId); 
            pstmt.executeUpdate();
            pstmt.close();
            
            conn.commit();
    		res.put("response", "操作成功！"); 
    		res.put("flag", "true");
        }catch(Exception e){
        	res.put("response", e.getMessage());  
     		res.put("flag", "false");
        }finally{
            rset.close();
            conn.close();
        } 
        response.flushBuffer();
		out.write(gson.toJson(res));
	}

}
