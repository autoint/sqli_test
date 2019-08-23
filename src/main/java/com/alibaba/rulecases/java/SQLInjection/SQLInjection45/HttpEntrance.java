package com.alibaba.rulecases.java.SQLInjection.SQLInjection45;

import java.util.HashMap;
import java.util.Map;

import com.alibaba.citrus.turbine.dataresolver.Param;


public class HttpEntrance {

	private UserInfoDAO userInfoDAO;

	public void execute(@Param("param") String param) throws Exception {
		Map<String,String> query = new HashMap<String,String>();
		if(!param.toLowerCase().equals("asc")||!param.toLowerCase().equals("desc")){
			return;
		}
		query.put("orderBy",param);
		fun(query);
	}

	public void fun(Map<String,String> query){
		userInfoDAO.query(query);
	}
}
