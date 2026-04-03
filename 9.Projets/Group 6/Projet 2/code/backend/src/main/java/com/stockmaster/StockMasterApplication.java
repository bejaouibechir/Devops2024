package com.stockmaster;

import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.cache.annotation.EnableCaching;

@SpringBootApplication
@EnableCaching
public class StockMasterApplication {
    public static void main(String[] args) {
        SpringApplication.run(StockMasterApplication.class, args);
    }
}
