package com.alibaba.rulecases.java.SQLInjection.SQLInjection31;
import java.util.List;

public interface UserInfoDAO {
	List<UserInfoDO> query(UserInfoQuery userInfoQuery);
}
