package com.alibaba.rulecases.java.SQLInjection.SQLInjection27;

import org.springframework.web.bind.annotation.RequestMapping;

public class HttpEntrance {

	private UserInfoDAO userInfoDAO;

	@RequestMapping
	public void execute(UserInfoQuery query) throws Exception {
		userInfoDAO.query(query);
	}
}
