-- conf.lua
function love.conf(t)
    t.window.title = "SlimSurvivor"
    t.window.icon = "assets/icon/SlimeIcon.png"
    t.window.width = 800        -- ความกว้างหน้าต่าง (ไม่จำเป็นในโหมด fullscreen)
    t.window.height = 600       -- ความสูงหน้าต่าง (ไม่จำเป็นในโหมด fullscreen)
    t.window.fullscreen = true  -- เปิดโหมด fullscreen


    -- 
    t.window.vsync = 0         -- เปิดการใช้ vertical sync (เพื่อป้องกันการฉีกของภาพ)
    t.window.msaa = 16

    t.window.resizable = true  -- ไม่ให้สามารถเปลี่ยนขนาดหน้าต่างได้ (สามารถปรับได้ตามต้องการ)
end
