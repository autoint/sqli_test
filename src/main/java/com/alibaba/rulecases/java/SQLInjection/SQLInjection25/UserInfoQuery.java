package com.alibaba.rulecases.java.SQLInjection.SQLInjection25;

import java.util.Date;

public class UserInfoQuery  extends BaseQuery{

	private Date gmtCreate;

	private Long id;

	public Date getGmtCreate() {
		return gmtCreate;
	}

	public void setGmtCreate(Date gmtCreate) {
		this.gmtCreate = gmtCreate;
	}

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}
}
