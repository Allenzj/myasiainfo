package com.asiainfo.dacp.dp.server.scheduler.sort;

import java.lang.reflect.Field;
import java.util.List;

public abstract class DpSorter {
	public final static int DESC = 1;
	public final static int ASC = 0;
	/**分组排序
	 * @param <T>*/
	public abstract <T> void  groupSort(List<T> list,final String groupFiled,final String sortFieldName, final int groupSortType,final int fieldSortType);
	/**简单排序*/
	public abstract <T> void  sort(List<T> list,String sortFieldName,int sortType);
	protected <T> Object getFeildValue(T object,String fieldName){
		Object value = null;
		Class<?> clz = object.getClass();
		Field[]   fields=   clz.getDeclaredFields(); 
		for(Field field:fields){
			if(field.getName().equalsIgnoreCase(fieldName)){
				field.setAccessible(true);
				try {
					value =  field.get(object);
				} catch (IllegalArgumentException e) {
					e.printStackTrace();
				} catch (IllegalAccessException e) {
					e.printStackTrace();
				}
			}
		}
		return value;
	}
}
