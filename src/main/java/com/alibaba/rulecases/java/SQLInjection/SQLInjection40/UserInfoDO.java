package com.alibaba.rulecases.java.SQLInjection.SQLInjection40;
import java.util.Date;

public class UserInfoDO {
	private Long id;

	private Date gmtCreate;

	private String name;

	public Long getId() {
		return id;
	}

	public void setId(Long id) {
		this.id = id;
	}

	public Date getGmtCreate() {
		return gmtCreate;
	}

	public void setGmtCreate(Date gmtCreate) {
		this.gmtCreate = gmtCreate;
	}

	public String getName() {
		return name;
	}

	public void setName(String name) {
		this.name = name;
	}
}


