package com.alibaba.rulecases.java.SQLInjection.SQLInjection23;
import java.util.List;

public interface UserInfoDAO {
	List<UserInfoDO> query(UserInfoQuery userInfoQuery);
}
