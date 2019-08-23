package com.alibaba.rulecases.java.SQLInjection.SQLInjection52;

import java.util.Date;

public class UserInfoQuery  {
	protected String orderBy ;

	private Date gmtCreate;

	private Long id;

	public String getOrderBy() {
		return orderBy;
	}

	public void setOrderBy(String orderBy) {
		this.orderBy = orderBy;
	}

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
