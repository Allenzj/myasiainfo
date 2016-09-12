package com.asiainfo.dacp.dp.server.scheduler.sort;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.Collections;
import java.util.Comparator;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Component;
@Component
public class SchedulePrioritySorter extends DpSorter {
	/**
	 * list 待排序队列
	 * groupFiled 【priLevel】
	 * sortFiled 批次
	 * groupSortType 【DpSorter.DESC 值为1】
	 * sortType 【DpSorter.ASC 值为0】
	 */
	public <T> void groupSort(List<T> list, final String groupFiled,
			final String sortFiled, int groupSortType, final int sortType) {
		List<T> resList = new ArrayList<T>();
		List<T> itemList =  null;
		String groupKey  =  null;
		Map<String,List<T>> groupMap = new HashMap<String,List<T>>();
		for(T obj:list){//遍历待执行队列
			Object group = this.getFeildValue(obj, groupFiled);//获取优先级的值
			if(group==null){
				groupKey="null";
			}else{
				groupKey = group.toString();//赋值变量
			}
			itemList = groupMap.get(groupKey);
			if(itemList != null ){
				itemList.add(obj);
			}else{
				itemList = new ArrayList<T>();
				itemList.add(obj);
				groupMap.put(groupKey, itemList);
			}
		}
		List<Object> groupKeyList = Arrays.asList(groupMap.keySet().toArray());
		sort(groupKeyList,groupFiled,groupSortType);
		List<T> subItemList = null;
		for(Object group:groupKeyList){
			subItemList = groupMap.get(group.toString());
			if(subItemList == null ){
				return ;
			}
			sort(subItemList,sortFiled,sortType);
			resList.addAll(subItemList);
		}
		list.clear();
		list.addAll(resList);
	}
	public <T> void sort(List<T> list, final String sortFieldName,
			final int sortType) {
		Comparator<Object> com = new Comparator<Object>() {
			public int compare(Object o1, Object o2) {
				int res = 0;
				Object val1 = getFeildValue(o1, sortFieldName);
				Object val2 = getFeildValue(o2, sortFieldName);
				if (val1 == null || val2 == null) {
					return res;
				}
				if (val1 instanceof Integer) {
					res =  Integer.parseInt(val1.toString())
							- Integer.parseInt(val2.toString());
				} else {
					res = val1.toString().compareTo(val2.toString());
				}
				if (sortType == DpSorter.DESC) {
					return 0-res;
				} else {
					return res;
				}
			}
		};
		Collections.sort(list, com);
	}
}
