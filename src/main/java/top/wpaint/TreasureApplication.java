package top.wpaint;

import lombok.extern.slf4j.Slf4j;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;

@Slf4j
@SpringBootApplication
public class TreasureApplication {

    public static void main(String[] args) {
        SpringApplication.run(TreasureApplication.class, args);
        log.info("TreasureApplication started");
    }
}
