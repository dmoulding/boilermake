#pragma once

#include <string>

class Animal {
public:
    void talk () const;

protected:
    Animal (std::string name);

    std::string m_sound;

private:
    std::string m_name;
};
