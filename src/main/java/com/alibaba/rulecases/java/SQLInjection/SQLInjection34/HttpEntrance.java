package com.alibaba.rulecases.java.SQLInjection.SQLInjection34;

import java.io.File;
import java.io.IOException;
import java.sql.PreparedStatement;
import java.sql.Connection;
import java.sql.DriverManager;

import com.alibaba.citrus.turbine.dataresolver.Param;


public class HttpEntrance {

	private UserInfoDAO userInfoDAO;

	public void execute(@Param("param") String param) throws Exception {
		UserInfoQuery query = new UserInfoQuery();
		//query.setOrderBy(param);
		//query.setId(param);
		fun(query);
	}

	public void fun(UserInfoQuery query){
		userInfoDAO.query(query);
	}
}
