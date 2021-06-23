package com.group5.springboot.controller.cart;

import java.sql.Date;
import java.text.SimpleDateFormat;
import java.util.*;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.bind.annotation.SessionAttributes;

import com.group5.springboot.model.cart.OrderInfo;
import com.group5.springboot.model.product.ProductInfo;
import com.group5.springboot.model.user.User_Info;
import com.group5.springboot.service.cart.OrderService;

@SessionAttributes(names = "cart")
@Controller
@RequestMapping(path = "")
public class CartController {
	@Autowired // SDI ✔
	private OrderService orderService;
//	@Autowired // SDI ✔
	public List<ProductInfo> cart = new ArrayList<ProductInfo>();

	
	@GetMapping(value = {"/cart.controller"})
	public String toTestpage() {
		return "/cart/testpagee";
	}
	
//	@PostMapping(value = {"/cart.controller/cartIndex"})
	@GetMapping(value = {"/cart.controller/cartIndex"})
	public String toCartIndex() {
		refill();
		System.out.print("現在你的購物車 = ");
		cart.forEach(System.out::print);
		return "cart/cartIndex";
	}
	
	@PostMapping(value = {"/cart.controller/cartCheckout"})
	public String toCartCheckout() {
		refill();
		return "cart/cartCheckout";
	}
	
	@GetMapping(value = {"/cart.controller/cartAdmin"})
	public String toCartAdmin() {
		return "cart/cartAdmin";
	}
	

	@SuppressWarnings("unchecked")
	@GetMapping(value="/cart.controller/showCart", produces = "application/json; charset=UTF-8")
	@ResponseBody
	public List<ProductInfo> showCart(HttpSession session) {
		session.setAttribute("cart", cart);
		cart = (ArrayList<ProductInfo>) session.getAttribute("cart");
		System.out.println("*** 現在正在showCart()方法內 ***");
		System.out.println("cart = " + cart);
		System.out.println("*** showCart()方法結束 ***");
		return cart;
	}
	
	@SuppressWarnings("unchecked")
	@PostMapping(value = "/cart.controller/remove", produces = "application/json; charset=UTF-8")
	@ResponseBody
	public List<ProductInfo> removeProductFromCart(@RequestParam String[] ckboxValues, HttpSession session) {
		cart = (ArrayList<ProductInfo>) session.getAttribute("cart");
		System.out.println(ckboxValues);
		for (int i = 0; i < ckboxValues.length; i++) {
			int ckIndex = Integer.parseInt(ckboxValues[i]);
			cart.remove(ckIndex - i);
			System.out.println(ckboxValues[i]);
		}
		session.setAttribute("cart", cart);
		return cart;
	}
	
	@GetMapping(value = "/cart.controller/index")
	public String backToMainPage() {
		return "/index";
	}
	
	@PostMapping("/cart.controller/pay")
	public String pay() {
		
		// (1) 取得O_ID：查出最新的O_ID ❌
		// (2) 取得U_ID，U_FirstName，U_LastName，U_Email
		ArrayList<User_Info> fakeUserInfos = new ArrayList<User_Info>();
		User_Info fakeUserInfo00 = new User_Info();
		fakeUserInfo00.setU_id("OWO");
		fakeUserInfo00.setU_psw("tkym999");
		fakeUserInfo00.setU_birthday(new Date(System.currentTimeMillis()));
		fakeUserInfo00.setU_lastname("Tokoyami");
		fakeUserInfo00.setU_firstname("Towa");
		fakeUserInfo00.setU_email("akuma@tmt.jp");
		fakeUserInfo00.setU_gender("female");
		fakeUserInfo00.setU_address("Earth");
		fakeUserInfo00.setU_img(null);
		fakeUserInfo00.setMimeType("image/jpeg");
		fakeUserInfos.add(fakeUserInfo00);
		
		// (3) 取得O_Date (使用SimpleDateFormat)
		SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
		Calendar calendar = Calendar.getInstance();
		calendar.setTimeInMillis(System.currentTimeMillis());
		String now = sdf.format(calendar.getTime());
		
		// (4) 取得O_Amt
		 Integer O_Amt = 0;
		 for (int i = 0; i < this.cart.size(); i++) {
			O_Amt += this.cart.get(i).getP_Price();
		}
		 
		// 把OrderBean的資料寫進去Database
		for(int i = 0; i < cart.size(); i++) {
			OrderInfo orderBean = new OrderInfo();
			orderBean.setO_id(0); // PK // 會受IDENTITY(1, 1)的影響被複寫掉
			orderBean.setP_id(cart.get(i).getP_ID()); // FK
			orderBean.setP_name(cart.get(i).getP_Name()); // FK
			orderBean.setP_price(cart.get(i).getP_Price()); // FK
			orderBean.setU_id(fakeUserInfos.get(0).getU_id()); // FK // fake
			orderBean.setU_firstname(fakeUserInfos.get(0).getU_firstname()); // FK // fake
			orderBean.setU_lastname(fakeUserInfos.get(0).getU_lastname()); // FK // fake
			orderBean.setU_email(fakeUserInfos.get(0).getU_email()); // FK // fake
			orderBean.setO_status("DONE");
			orderBean.setO_date(now);
			orderBean.setO_amt(O_Amt);
			orderService.insert(orderBean);
		}

		this.cart = new ArrayList<ProductInfo>();
		System.out.println("購買成功，感謝您！");
		return "/cart/cartThanks";
	}

	@GetMapping(value = "/cart.controller/initAdminPageData", produces = "application/json; charset=UTF-8")
	@ResponseBody
	public List<OrderInfo> initAdminPageData(){
		List<OrderInfo> a = orderService.selectTop20();
		for (int i = 0; i < a.size(); i++) {
			System.out.println(a.get(i));
		}
		return a; 
	}
	
	@GetMapping("/test2")
	@ResponseBody
	public String testtt() {
		OrderInfo order = new OrderInfo(50, 100, "ww", 200, "2s", "qew", 
				"u_lastewname", "@@", "ww", "1907-01-23 00:11:22.0", 20);
		boolean insertStatus = (orderService.insert(order) != null)? true : false;
		System.out.println("good? " + insertStatus);
		return "ok";
	} 
	
	@PostMapping(value = "/cart.controller/deleteAdmin")
	@ResponseBody
	public Map<String, String> adminDelete(@RequestParam String o_id) {
		
		OrderInfo order = new OrderInfo();
		order.setO_id(Integer.parseInt(o_id));
		boolean deleteStatus = (orderService.delete(order))? true : false;
		String msg = "oid = " + o_id + ((deleteStatus)?  "：刪除成功✔" : "：刪除失敗❌");
		HashMap<String, String> resultMap = new HashMap<>();
		resultMap.put("state", msg);
		
		return resultMap;
	}
	
	@PostMapping(value = "/cart.controller/updateAdmin")
	@ResponseBody
	public Map<String, String> adminUpdate(@RequestBody OrderInfo order) {
		boolean updateStatus = (orderService.update(order))? true : false;
		String msg = "oid = " + order.getO_id() + ((updateStatus)?  "：修改成功✔" : "：修改失敗❌");
		HashMap<String, String> resultMap = new HashMap<>();
		resultMap.put("state", msg);
		
		return resultMap;
	}
//	
//	@PostMapping(value = "/cart.controller/insertAdmin")
//	@ResponseBody
//	public Map<String, String> adminInsert(@RequestParam String o_id, @RequestParam String p_id, @RequestParam String p_name, @RequestParam String p_price,
//			@RequestParam String u_id, @RequestParam String u_firstname, @RequestParam String u_lastname, @RequestParam String u_email, 
//			@RequestParam String o_status, @RequestParam String o_date, @RequestParam String o_amt) {
//		// 下面的O_ID有跟沒有一樣
//		Order order = new Order(9999999, Integer.parseInt(p_id), p_name, Integer.parseInt(p_price), u_id, u_firstname, 
//				u_lastname, u_email, o_status, o_date, Integer.parseInt(o_amt));
//		boolean insertStatus = (orderService.insert(order) != null)? true : false;
//		String msg = (insertStatus)? "新增成功！" : "新增失敗 :^)";
//		HashMap<String, String> resultMap = new HashMap<>();
//		resultMap.put("state", msg);
//		
//		return resultMap;
//	}
	
	@PostMapping(value = "/cart.controller/insertAdmin")
	@ResponseBody
	public Map<String, String> adminInsert(@RequestBody OrderInfo order) {
		// 下面的O_ID有跟沒有一樣
//		Order order = new Order(9999999, Integer.parseInt(p_id), p_name, Integer.parseInt(p_price), u_id, u_firstname, 
//				u_lastname, u_email, o_status, o_date, Integer.parseInt(o_amt));
		boolean insertStatus = (orderService.insert(order) != null)? true : false;
		String msg = (insertStatus)? "新增成功！" : "新增失敗 :^)";
		HashMap<String, String> resultMap = new HashMap<>();
		resultMap.put("state", msg);
		
		return resultMap;
	}
	
	// 純粹測試用；最後用不到
	// 每次經過這個Controller都會跑這個block
	// 測試用。cart如果是空的，會自動補3件下列商品作為測試
	
	private void refill() {
		System.out.println("正在檢查你的cart是不是空的...");
		
		if(cart.size() == 0 || cart == null) {
			byte[] aa = {1, 2};
			ProductInfo fakeProductBean1 = new ProductInfo();
			fakeProductBean1.setP_ID(3000);
			fakeProductBean1.setP_Name("EN_Speaking");
			fakeProductBean1.setP_Class("EN");
			fakeProductBean1.setP_Price(500);
			fakeProductBean1.setP_DESC("nice!!!");
			fakeProductBean1.setU_ID("fbk001");
			fakeProductBean1.setP_createDate("1999-11-22");
			fakeProductBean1.setP_Img(aa);
			fakeProductBean1.setP_Video(aa);
			
			if(cart == null) {
				cart = new ArrayList<ProductInfo>();
			}
			cart.add(fakeProductBean1);
			cart.add(fakeProductBean1);
			cart.add(fakeProductBean1);
			cart.add(fakeProductBean1);
			cart.add(fakeProductBean1);
		}
	}
	
}